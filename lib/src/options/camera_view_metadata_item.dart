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
  final String path;
  final OverlayContentSource source;

  OverlayContent({required this.path, required this.source});
}
