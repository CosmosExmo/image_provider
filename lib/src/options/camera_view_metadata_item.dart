// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../../image_provider.dart';

class ImageMetadata {
  final String? title;
  final OverlayContent? overlayContent;

  ImageMetadata({this.title, this.overlayContent});

  ImageMetadata setEmpty() {
    return ImageMetadata(title: title);
  }

  ImageMetadata copyWith({
    String? title,
    OverlayContent? overlayContent,
  }) {
    return ImageMetadata(
      title: title ?? this.title,
      overlayContent: overlayContent ?? this.overlayContent,
    );
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

  @override
  bool operator ==(covariant OverlayContent other) {
    if (identical(this, other)) return true;

    return other.content == content && other.source == source;
  }

  @override
  int get hashCode => content.hashCode ^ source.hashCode;
}
