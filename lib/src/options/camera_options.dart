part of image_provider;

class CameraViewOptions {
  CameraViewOptions({this.cameraItems = const [],this.cameraItemsMap = const {}}){
    cameraItemsMap = {
      for (final item in cameraItems) cameraItems.indexOf(item): item,
    };
  }

  Map<int,CameraItemMetadata> cameraItemsMap;
  final List<CameraItemMetadata> cameraItems;
}
