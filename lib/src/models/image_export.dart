import 'dart:typed_data';

import 'package:image_provider/src/app/enums.dart';

class ImageExport {
  final RepositoryType? repositoryType;
  List<ContentData?>? images;

  bool get hasImage => images != null && images!.isNotEmpty;

  ImageExport({
    this.repositoryType,
    this.images,
  }) {
    images = [];
  }

  ImageExport.camera({
    this.repositoryType = RepositoryType.camera,
    this.images,
  }) {
    images = [];
  }

  ImageExport.gallery({
    this.repositoryType = RepositoryType.gallery,
    this.images,
  }) {
    images = [];
  }

  ImageExport.local({
    this.repositoryType = RepositoryType.local,
    this.images,
  }) {
    images = [];
  }

  ImageExport.files({
    this.repositoryType = RepositoryType.files,
    this.images,
  }) {
    images = [];
  }
}

class ContentData {
  final String extension;
  final String? fileName;
  Uint8List? data;

  ContentData({
    required this.extension,
    this.fileName,
    this.data,
  });

  factory ContentData.fromData(String? extension, Uint8List? data,
      {String? fileName}) {
    return ContentData(
      extension: extension ?? "jpg",
      fileName: fileName,
      data: data,
    );
  }
}
