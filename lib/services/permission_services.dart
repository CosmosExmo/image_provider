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
    bool status = await Permission.camera.isGranted;

    if (!status) {
      await Permission.camera.request();
      status = await Permission.camera.isGranted;
    }

    return status;
  }
}
