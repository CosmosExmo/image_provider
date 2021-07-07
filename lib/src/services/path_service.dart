import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'permission_services.dart';

class PathService {
  final _permissionService = PermissionServices();

  Future<String?> getImagePath() async {
    final status = await _permissionService.getStorageRequest();

    if (status) {
      final extDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final path = '${extDir?.path}/Images/';
      return path;
    }
    return null;
  }
}
