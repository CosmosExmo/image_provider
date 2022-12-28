import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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

  Future<PermissionStatus> getCameraRequest() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var version = iosInfo.systemVersion;
      final versionDouble = double.tryParse(version!.substring(0, 4));
      if (versionDouble != null && versionDouble >= 12.0) {
        return PermissionStatus.granted;
      }
    }

    final status = await Permission.camera.request();

    return status;
  }
}
