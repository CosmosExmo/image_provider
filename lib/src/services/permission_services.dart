import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionServices {
  Future<bool> getStorageRequest() async {
    bool status = await Permission.storage.isGranted;

    if (!status) {
      await Permission.storage.request();
      status = await Permission.storage.isGranted;
    }

    return status;
  }

  Future<bool> getCameraRequest() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var version = iosInfo.systemVersion;
      final versionDouble = double.tryParse(version.substring(0, 4));
      if (versionDouble != null && versionDouble >= 14.0) {
        return true;
      } else {
        final per = await Permission.camera.request();
        if (per == PermissionStatus.permanentlyDenied) {
          return true;
        } else {
          return await Permission.camera.isGranted;
        }
      }
    }

    bool status = await Permission.camera.isGranted;

    if (!status) {
      await Permission.camera.request();
      status = await Permission.camera.isGranted;
    }

    return status;
  }
}
