import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_provider/src/app/enums.dart';
import 'package:image_provider/src/models/image_export.dart';
import 'package:image_provider/src/services/permission_services.dart';
import 'package:image_provider/src/utils/compress_image.dart';

class CameraViewModel with ChangeNotifier {
  static late List<CameraDescription> _availableCameras = [];

  late CameraController? _controller;

  ImageExport? _imageExport;

  FlashMode? _flashType;

  String? _lastImage;

  bool _viewDidLoad = false;
  bool get viewDidLoad => _viewDidLoad;

  final _permissionService = PermissionServices();

  bool _hasCameraPermission = false;

  CameraController? get controller => _controller;
  FlashMode? get flashType => _flashType;
  String? get lastImage => _lastImage;
  bool get hasCameraPermission => _hasCameraPermission;

  double _baseScale = 1.0;
  int _pointers = 0;

  late double? _maxZoomLevel;
  late double? _minZoomLevel;

  Future<void> getData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _flashType = FlashMode.auto;
    _imageExport = ImageExport.camera();
    await requestCameraPermission();
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
    _hasCameraPermission = permissionStatus;
  }

  Future<void> captureImage() async {
    try {
      await HapticFeedback.mediumImpact();
      _focusTimer =
          Timer(const Duration(milliseconds: 300), _onPictureTakenTimerEnd);
      _showPicturaTakenWidget = true;
      notifyListeners();
      final _imageFile = await _controller?.takePicture();
      _lastImage = _imageFile?.path;
      final _params = ImageCompressParams(
          repositoryType: RepositoryType.camera, imageData: _imageFile?.path);
      final value = await getImageCompressed(_params);
      _imageExport?.images?.add(value);
      notifyListeners();
    } catch (_) {}
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

    final _currentScale = (_baseScale * details.scale)
        .clamp(_minZoomLevel!, _maxZoomLevel!)
        .toDouble();

    await controller!.setZoomLevel(_currentScale);
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
  Timer? _pictureTakenTimer;

  Offset _tabOffset = Offset.zero;
  Offset get tabOffset => _tabOffset;

  bool _showFocusWidget = false;
  bool get showFocusWidget => _showFocusWidget;

  bool _showPicturaTakenWidget = false;
  bool get showPicturaTakenWidget => _showPicturaTakenWidget;

  void _onFocusTimerEnd() {
    _showFocusWidget = false;
    notifyListeners();
  }

  void _onPictureTakenTimerEnd() {
    _showPicturaTakenWidget = false;
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
    if (_pictureTakenTimer != null && _pictureTakenTimer!.isActive) {
      _pictureTakenTimer!.cancel();
    }
    await _controller?.dispose();
  }

  Future<void> pauseCamera() async {
    await _controller?.pausePreview();
  }

  Future<void> resumeCamera() async {
    await _controller?.resumePreview();
  }
}
