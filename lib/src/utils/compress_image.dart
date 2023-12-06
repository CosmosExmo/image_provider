import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';


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

Future<Uint8List> getUInt8List(Asset resimData) async {
  List<int> uInt8List = [];
  ByteData byteData = await resimData.getThumbByteData(400, 600);
  uInt8List = byteData.buffer.asUint8List();
  return uInt8List as Uint8List;

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
