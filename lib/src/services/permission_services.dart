
import 'package:permission_asker/permission_asker.dart';

class PermissionServices {
  Future<bool> getStorageRequest() async {
    PermissionStatus status = PermissionStatus.denied;

    PermissionAsker(onPermissionData: (value) {
      status = value.status;
    });

    status = await Permission.storage.request();

    return status.isGranted;
  }

  Future<PermissionStatus> getCameraRequest() async {
    PermissionStatus status = PermissionStatus.denied;

    PermissionAsker(
        requestTimes: 0,
        onPermissionData: (value) {
          status = value.status;
        });

    status = await Permission.camera.request();

    return status;
  }
}