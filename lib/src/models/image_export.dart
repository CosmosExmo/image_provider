// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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

  List<ContentData?> get allImages => _images ?? [];

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

  @override
  bool operator ==(covariant ContentData other) {
    if (identical(this, other)) return true;

    return other.extension == extension &&
        other.path == path &&
        other.fileName == fileName &&
        other.metadata == metadata &&
        other.data == data;
  }

  @override
  int get hashCode {
    return extension.hashCode ^
        path.hashCode ^
        fileName.hashCode ^
        metadata.hashCode ^
        data.hashCode;
  }
}
