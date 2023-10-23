import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_provider/src/app/enums.dart';

@immutable
class ImageCompressParams {
  final RepositoryType repositoryType;
  final dynamic imageData;

  const ImageCompressParams({
    required this.repositoryType,
    required this.imageData,
  });
}

Future<Uint8List?> getImageCompressed(ImageCompressParams params) async {
  late Uint8List returnData;

  if (params.repositoryType == RepositoryType.camera) {
    returnData = File(params.imageData).readAsBytesSync();
  }

  if (params.repositoryType == RepositoryType.gallery) {
    if (params.imageData is String) {
      returnData = File(params.imageData).readAsBytesSync();
      return returnData;
    }
    returnData = await getUInt8List(params.imageData);
  }

  if (params.repositoryType == RepositoryType.files) {
    returnData = params.imageData.bytes;
    return returnData;
  }

  final compressedImage = await compressList(returnData);

  return compressedImage;
}

Future<Uint8List> getUInt8List(XFile resimData) async {
  return await resimData.readAsBytes();
}

Future<Uint8List?> compressList(Uint8List list) async {
  try {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 600,
      minWidth: 800,
      quality: 80,
    );
    return result;
  } catch (_) {
    return null;
  }
}
