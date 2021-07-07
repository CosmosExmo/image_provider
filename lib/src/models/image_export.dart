import 'dart:typed_data';

import 'package:image_provider/src/app/enums.dart';

class ImageExport {
  final RepositoryType? repositoryType;
  List<Uint8List?>? images;

  bool get hasImage => this.images != null && this.images!.isNotEmpty;

  ImageExport({
    this.repositoryType,
    this.images,
  });

  ImageExport.camera({
    this.repositoryType = RepositoryType.Camera,
    this.images,
  }) {
    this.images = [];
  }

  ImageExport.gallery({
    this.repositoryType = RepositoryType.Gallery,
    this.images,
  }) {
    this.images = [];
  }

  ImageExport.local({
    this.repositoryType = RepositoryType.Local,
    this.images,
  }) {
    this.images = [];
  }
}
