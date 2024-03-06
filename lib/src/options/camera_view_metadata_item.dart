part of '../../image_provider.dart';

class ImageMetadata {
  final String? title;
  final OverlayContent? overlayContent;

  ImageMetadata({this.title, this.overlayContent});

  ImageMetadata setEmpty() {
    return ImageMetadata(title: title);
  }
}

enum OverlayContentSource { network, file }

class OverlayContent {
  //Either a network url or a File
  final dynamic content;
  final OverlayContentSource source;

  //Make sure the content is String or File
  OverlayContent({required this.content, required this.source})
      : assert(source == OverlayContentSource.network
            ? content is String
            : content is File);
}
