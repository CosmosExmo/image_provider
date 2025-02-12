import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../image_provider.dart';

@immutable
class ImageCompressParams {
  final RepositoryType repositoryType;
  final dynamic imageData;

  const ImageCompressParams({
    required this.repositoryType,
    required this.imageData,
  });
}

Future<List<Uint8List>> getImageCompressedList(
    List<ImageCompressParams> params) async {
  List<Uint8List> returnData = [];

  for (var param in params) {
    if (param.repositoryType == RepositoryType.camera) {
      returnData.add(File(param.imageData).readAsBytesSync());
    }

    if (param.repositoryType == RepositoryType.gallery) {
      returnData.add(await getUInt8List(param.imageData));
    }

    if (param.repositoryType == RepositoryType.files) {
      returnData.add(param.imageData.bytes);
    }
  }
  return returnData;
}

Future<(Uint8List, String?)> getImageCompressed(
    ImageCompressParams params) async {
  late Uint8List returnData;

  if (params.repositoryType == RepositoryType.camera) {
    returnData = File(params.imageData).readAsBytesSync();
  }

  if (params.repositoryType == RepositoryType.gallery) {
    if (params.imageData is String) {
      returnData = File(params.imageData).readAsBytesSync();
      return (returnData, params.imageData as String);
    }
    returnData = await getUInt8List(params.imageData);
  }

  if (params.repositoryType == RepositoryType.files) {
    returnData = params.imageData.bytes;
    return (returnData, null);
  }

  final compressedImage = await compressList(returnData);

  return (compressedImage, params.imageData as String);
}

Future<Uint8List> getUInt8List(XFile resimData) async {
  var byteData = await resimData.readAsBytes();
  return byteData;
}

Future<Uint8List> compressList(Uint8List list) async {
  try {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 600,
      minWidth: 800,
      quality: 80,
    );
    return result;
  } catch (_) {
    rethrow;
  }
}
