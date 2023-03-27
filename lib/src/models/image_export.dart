import 'dart:typed_data';

import '../../image_provider.dart';

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
  final String? path;
  final String? fileName;
  bool dummy;
  Uint8List? data;

  ContentData({
    required this.extension,
    required this.path,
    this.fileName,
    this.dummy = false,
    this.data,
  });

  factory ContentData.dummy() {
    return ContentData(
      path: null,
      dummy: true,
      extension: "jpg",
      fileName: "",
      data: Uint8List(0),
    );
  }

  factory ContentData.fromData(String? extension, Uint8List? data,
      {String? fileName, String? path}) {
    return ContentData(
      path: path ?? "",
      extension: extension ?? "jpg",
      fileName: fileName,
      data: data,
    );
  }
}
