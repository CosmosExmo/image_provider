part of image_provider;

class CameraViewOptions {
  CameraViewOptions(
      {this.cameraItems = const [],
      this.cameraItemsMap = const {},
      this.cardColor = Colors.red,
      this.textColor = Colors.white,
      this.iconColor = Colors.white,
      this.galleryPhotoTitleTextStyle}) {
    cameraItemsMap = {
      for (final item in cameraItems) cameraItems.indexOf(item): item,
    };
  }

  Map<int, CameraItemMetadata> cameraItemsMap;
  final List<CameraItemMetadata> cameraItems;
  final Color cardColor, textColor, iconColor;
  final TextStyle? galleryPhotoTitleTextStyle;
}
