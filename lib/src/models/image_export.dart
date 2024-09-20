import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../image_provider.dart';

class ImageExport {
  final RepositoryType? repositoryType;
  List<ContentData?>? _images;
  List<XFile>? imageassets;

  set imgssetter(List<ContentData?>? value) {
    _images = value;
  }

  set imgadder(ContentData? value) {
    _images!.add(value);
  }

  List<ContentData?> get allImages => _images ?? <ContentData>[];

  List<ContentData?> get images =>
      (_images ?? <ContentData>[]).where((img) => img != null).toList();

  bool get hasImage => _images != null && _images!.isNotEmpty;

  ImageExport({
    this.repositoryType,
  }) {
    _images = [];
  }

  ImageExport.camera({
    this.repositoryType = RepositoryType.camera,
  }) {
    _images = [];
  }

  ImageExport.gallery({
    this.repositoryType = RepositoryType.gallery,
  }) {
    _images = [];
  }

  ImageExport.local({
    this.repositoryType = RepositoryType.local,
  }) {
    _images = [];
  }

  ImageExport.files({
    this.repositoryType = RepositoryType.files,
  }) {
    _images = [];
  }
}

class ContentData {
  final String extension;
  final String path;
  final String? fileName;
  final ImageMetadata? metadata;
  Uint8List? data;

  ContentData({
    required this.extension,
    required this.path,
    this.fileName,
    this.metadata,
    this.data,
  });

  ContentData copyWith({
    String? extension,
    String? path,
    String? fileName,
    ImageMetadata? metadata,
    Uint8List? data,
  }) {
    return ContentData(
      extension: extension ?? this.extension,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      metadata: metadata ?? this.metadata,
      data: data ?? this.data,
    );
  }
  
}
