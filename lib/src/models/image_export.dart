import 'dart:typed_data';

import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

import '../../image_provider.dart';

class ImageExport {
  final RepositoryType? repositoryType;
  List<ContentData?>? _images;
  List<Asset>? imageassets;

  set imgssetter(List<ContentData?>? value) {
    _images = value;
  }

  set imgadder(ContentData? value) {
    _images!.add(value);
  }

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
