part of image_provider;

class CameraItemMetadata {
  final String? title;
  final ContentData? contentData;

    CameraItemMetadata({
    this.title,
    this.contentData
  });


  
  CameraItemMetadata copyWith({
    String? title,
    ContentData? contentData    
  }) {
    return CameraItemMetadata(
          title: title ?? this.title,
          contentData: contentData ?? this.contentData
    );
  }

  CameraItemMetadata setEmpty() {
    return CameraItemMetadata(
          title: title,
          contentData: null
    );
  }
}
