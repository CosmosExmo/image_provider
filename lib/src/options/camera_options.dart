part of '../../image_provider.dart';

class CameraViewOptions {
  const CameraViewOptions({
    this.imageMetadataList = const [],
    this.cardColor = Colors.red,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.galleryPhotoTitleTextStyle,
  });

  final List<ImageMetadata> imageMetadataList;
  final Color cardColor, textColor, iconColor;
  final TextStyle? galleryPhotoTitleTextStyle;
}
