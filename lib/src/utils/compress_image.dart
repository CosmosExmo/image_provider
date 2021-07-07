import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_provider/src/app/enums.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

Future<Uint8List?> getImageCompressed(
  RepositoryType repositoryType,
  dynamic imageData,
) async {
  late Uint8List returnData;

  if (repositoryType == RepositoryType.Camera) {
    returnData = File(imageData).readAsBytesSync();
  }

  if (repositoryType == RepositoryType.Gallery) {
    returnData = await getUInt8List(imageData);
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
  } catch (e) {
    print(e);
    return null;
  }
}