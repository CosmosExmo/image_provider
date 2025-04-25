part of '../../image_provider.dart';

class CameraViewOptions {
  const CameraViewOptions({
    this.imageMetadataList = const [],
    this.cardColor = Colors.red,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.galleryPhotoTitleTextStyle,
    this.appsSupportedOrientations = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  });

  final List<ImageMetadata> imageMetadataList;
  final Color cardColor, textColor, iconColor;
  final TextStyle? galleryPhotoTitleTextStyle;
  final List<DeviceOrientation> appsSupportedOrientations;
}
