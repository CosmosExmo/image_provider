// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_provider/image_provider.dart';
import 'package:image_provider/src/helpers/compress_image_helper.dart';
import 'package:image_provider/src/services/permission_services.dart';
import 'package:image_provider/src/utils/get_package_info.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class CameraViewModel with ChangeNotifier {
  CameraViewModel(
      CameraViewOptions options, CompressionOptions compressionOptions) {
    _options = options;
    _compressionOptions = compressionOptions;
  }

  late CameraViewOptions _options;
  late CompressionOptions _compressionOptions;

  Color? get cardColor => _options.cardColor;
  Color? get textColor => _options.textColor;
  Color? get iconColor => _options.iconColor;
  TextStyle? get galleryPhotoTitleTextStyle =>
      _options.galleryPhotoTitleTextStyle;

  final ImageExport _imageExport = ImageExport.camera();

  bool _viewDidLoad = false;
  bool get viewDidLoad => _viewDidLoad;

  final _permissionService = PermissionServices();

  PermissionStatus? _cameraPermissionStatus;

  PermissionStatus get cameraPermissionStatus =>
      _cameraPermissionStatus ?? PermissionStatus.denied;

  String get getCurrentVersion => PackageInfoHolder().packageVersion;

  Future<void> removeImageByIndex(int index) async {
    _imageExport.allImages.removeAt(index);
    notifyListeners();
  }

  List<ContentData> get contentDataList => _imageExport.images
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

  Future<void> getData() async {
    await requestCameraPermission();
    await initializeCurrentPermission();
    _viewDidLoad = true;
    notifyListeners();
  }

  Future<void> requestCameraPermission() async {
    final permissionStatus = await _permissionService.getCameraRequest();
    _cameraPermissionStatus =
        permissionStatus ? PermissionStatus.granted : PermissionStatus.denied;
  }

  Future<void> initializeCurrentPermission() async {
    final permissionStatus =
        await _permissionService.initializeCurrentPermission();
    _cameraPermissionStatus = permissionStatus;
  }

  void setShowPictureTakenWidget(bool value) {
    _showPictureTakenWidget = value;
    notifyListeners();
  }

  bool get hasUnCapturedImageMetaDataLeft {
    if (_options.imageMetadataList.isEmpty) {
      return false;
    }

    return capturingImageMetaData.title == null;
  }

  //Get first image metadata that isnt captured yet.
  ImageMetadata get capturingImageMetaData {
    final metadata = _options.imageMetadataList.firstWhere(
      (element) {
        if (_imageExport.allImages.isEmpty) {
          return true;
        }

        final isCaptured = _imageExport.allImages
            .where((imageContent) =>
                element.title == imageContent?.metadata?.title)
            .isNotEmpty;

        return !isCaptured;
      },
      orElse: () => ImageMetadata(),
    );
    return metadata;
  }

  Future<void> onPictureCapture(MediaCapture event) async {
    try {
      if (hasUnCapturedImageMetaDataLeft) {
        return;
      }

      if (event.status == MediaCaptureStatus.failure) {
        debugPrint("Failed to capture image: ${event.exception}");
        return;
      }

      if (event.status == MediaCaptureStatus.capturing) {
        debugPrint("Capturing image...");
        return;
      }

      if (!event.isPicture) {
        debugPrint("Not a picture capture event");
        return;
      }

      await HapticFeedback.mediumImpact();

      List<ImageCompressParams> params = [];
      event.captureRequest.when(
        single: (single) {
          if (single.file == null) {
            return;
          }

          final path = single.file!.path;
          params.add(ImageCompressParams(
            repositoryType: RepositoryType.camera,
            imageData: path,
          ));
        },
        multiple: (multiple) {
          final nonNullList = multiple.fileBySensor.values
              .where((element) => element != null)
              .toList();

          if (nonNullList.isEmpty) {
            return;
          }

          final paramsList = nonNullList.map((e) {
            final path = e!.path;
            return ImageCompressParams(
              repositoryType: RepositoryType.camera,
              imageData: path,
            );
          }).toList();
          params.addAll(paramsList);
        },
      );

      final imageList = await Future.wait(
        params.map(
          (e) => CompressImageHelper(_compressionOptions).getImageCompressed(e),
        ),
      );

      final contentList = imageList.map(
        (e) {
          final content = ContentData(
            extension: "jpg",
            path: e.$2!,
            data: e.$1,
            metadata: capturingImageMetaData,
          );
          return content;
        },
      ).toList();

      _imageExport.allImages.addAll(contentList);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to capture image: $e");
    }
  }

  bool _showPictureTakenWidget = false;
  bool get showPictureTakenWidget => _showPictureTakenWidget;

  Future<void> openCameraRollBottomSheet(BuildContext context) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (bottomSheetContext) => [
        SliverWoltModalSheetPage(
          mainContentSliversBuilder: (context) => [
            CameraRollContentWidget(this),
          ],
        )
      ],
    );
    notifyListeners();
  }

  Future<void> _setDefaultOrientations() async {
    await SystemChrome.setPreferredOrientations(
        _options.appsSupportedOrientations);
  }

  void returnData(BuildContext context) async {
    await _setDefaultOrientations();
    Navigator.pop(context, _imageExport);
  }

  @override
  void dispose() {
    _setDefaultOrientations();
    super.dispose();
  }
}
