import 'dart:typed_data';

import 'package:image_provider/src/app/enums.dart';

class ImageExport {
  final RepositoryType? repositoryType;
  List<Uint8List?>? images;

  bool get hasImage => images != null && images!.isNotEmpty;

  ImageExport({
    this.repositoryType,
    this.images,
  });

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
