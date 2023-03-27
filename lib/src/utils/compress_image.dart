import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

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

Future<Uint8List?> getImageCompressed(ImageCompressParams params) async {
  late Uint8List returnData;

  if (params.repositoryType == RepositoryType.camera) {
    returnData = File(params.imageData).readAsBytesSync();
  }

  if (params.repositoryType == RepositoryType.gallery) {
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
  ByteData byteData = await resimData.getByteData();
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
