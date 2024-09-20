// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_provider/image_provider.dart';
import 'package:image_provider/src/services/permission_services.dart';
import 'package:image_provider/src/utils/compress_image.dart';
import 'package:image_provider/src/utils/get_package_info.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class CameraViewModel with ChangeNotifier {
  CameraViewModel(CameraViewOptions options) {
    _options = options;
  }

  late CameraViewOptions _options;

  Color? get cardColor => _options.cardColor;
  Color? get textColor => _options.textColor;
  Color? get iconColor => _options.iconColor;
  TextStyle? get galleryPhotoTitleTextStyle =>
      _options.galleryPhotoTitleTextStyle;

  static List<CameraDescription> _availableCameras = [];

  CameraController? _controller;
  ImageExport? _imageExport;

  late AnimationController _animationController;
  AnimationController get animationController => _animationController;

  setAnimationController(AnimationController value) {
    _animationController = value;
  }

  String? _lastImage;

  bool _viewDidLoad = false;
  bool get viewDidLoad => _viewDidLoad;

  final _permissionService = PermissionServices();

  PermissionStatus? _cameraPermissionStatus;

  CameraController? get controller => _controller;

  String? get lastImage => _lastImage;
  PermissionStatus get cameraPermissionStatus =>
      _cameraPermissionStatus ?? PermissionStatus.denied;

  String get getCurrentVersion => PackageInfoHolder().packageVersion;

  FlashMode? _flashType;
  FlashMode? get flashType => _flashType;

  double _baseScale = 1.0;
  int _pointers = 0;
  int currentIndex = 0;

  late double? _maxZoomLevel;
  late double? _minZoomLevel;

  Future<void> removeImageByIndex(int index) async {
    _imageExport?.allImages.removeAt(index);
    notifyListeners();
  }

  List<ContentData> get contentDataList =>
      _imageExport?.images
          .where((element) => element != null)
          .map((e) => e!)
          .toList() ??
      <ContentData>[];

  Future<void> getData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _flashType = FlashMode.auto;
    _imageExport = ImageExport.camera();
    await requestCameraPermission();
    await initializeCurrentPermission();
    await _initCamera();
    _viewDidLoad = true;
    notifyListeners();
  }

  Future<void> _initCamera() async {
    if (_availableCameras.isEmpty) {
      await _fetchAvailableCameras();
    }

    _controller = CameraController(
      _availableCameras[0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    if (!cameraPermissionStatus.isGranted) {
      return;
    }

    await _controller?.initialize();

    await Future.wait([
      _controller!.getMaxZoomLevel().then((value) => _maxZoomLevel = value),
      _controller!.getMinZoomLevel().then((value) => _minZoomLevel = value),
    ]);
  }

  Future<void> _fetchAvailableCameras() async {
    _availableCameras = await availableCameras();
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

    return capturingImageMetaData == null ||
        capturingImageMetaData?.title == null;
  }

  //Get first image metadata that isnt captured yet.
  ImageMetadata? get capturingImageMetaData {
    return _options.imageMetadataList.firstWhere(
      (element) {
        if (_imageExport == null) {
          return true;
        }

        if (_imageExport?.allImages.isEmpty ?? true) {
          return true;
        }

        return !_imageExport!.allImages
            .where((imageContent) => element == imageContent?.metadata)
            .isNotEmpty;
      },
      orElse: () => ImageMetadata(),
    );
  }

  Future<void> captureImage() async {
    try {
      if (_controller?.value.isInitialized != true) {
        return;
      }

      if (hasUnCapturedImageMetaDataLeft) {
        return;
      }

      await HapticFeedback.mediumImpact();
      setShowPictureTakenWidget(true);
      final imageFile = await _controller?.takePicture();
      _lastImage = imageFile?.path;
      final params = ImageCompressParams(
        repositoryType: RepositoryType.camera,
        imageData: imageFile?.path,
      );
      final value = await getImageCompressed(params);
      final content = ContentData(
        extension: "jpg",
        path: imageFile!.path,
        data: value,
        metadata: capturingImageMetaData,
      );
      _imageExport?.imgadder = content;
      setShowPictureTakenWidget(false);
    } catch (_) {
      setShowPictureTakenWidget(false);
    }
  }

  void setFlashMode(FlashMode value) async {
    _flashType = value;
    await _controller?.setFlashMode(value);
    notifyListeners();
  }

  void onPointerDown() {
    _pointers++;
  }

  void onPointerUp() {
    _pointers--;
  }

  void handleScaleStart(ScaleStartDetails details) {
    _baseScale = 1.0;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) {
      return;
    }

    if (_minZoomLevel == null || _maxZoomLevel == null) {
      return;
    }

    final currentScale = (_baseScale * details.scale)
        .clamp(_minZoomLevel!, _maxZoomLevel!)
        .toDouble();

    await controller!.setZoomLevel(currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    _tabOffset = Offset(details.localPosition.dx, details.localPosition.dy);
    _focusTimer = Timer(const Duration(milliseconds: 300), _onFocusTimerEnd);
    _showFocusWidget = true;
    notifyListeners();

    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Timer? _focusTimer;

  Offset _tabOffset = Offset.zero;
  Offset get tabOffset => _tabOffset;

  bool _showFocusWidget = false;
  bool get showFocusWidget => _showFocusWidget;

  bool _showPictureTakenWidget = false;
  bool get showPictureTakenWidget => _showPictureTakenWidget;

  void _onFocusTimerEnd() {
    _showFocusWidget = false;
    notifyListeners();
  }

  void returnData(BuildContext context) async {
    await disposeCamera();
    Navigator.pop(context, _imageExport);
  }

  Future<void> disposeCamera() async {
    if (_focusTimer != null && _focusTimer!.isActive) {
      _focusTimer!.cancel();
    }
    await _controller?.dispose();
  }

  Future<void> pauseCamera() async {
    await _controller?.pausePreview();
  }

  Future<void> resumeCamera() async {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      await _initCamera();
    }

    await _controller?.resumePreview();
  }

  Future<void> openCameraRollBottomSheet(BuildContext context) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (bottomSheetContext) => [
        SliverWoltModalSheetPage(
          pageTitle: const Text("Fotoğraflar"),
          mainContentSliversBuilder: (context) => [
            CameraRollContentWidget(this),
          ],
        )
      ],
    );
    notifyListeners();
  }
}
