import 'package:permission_asker/permission_asker.dart';

class PermissionServices {
  Future<bool> getStorageRequest() async {
    final status1 = await Permission.storage.request();
    final status2 = await Permission.photos.request();
    final status3 = await Permission.manageExternalStorage.request();
    final isGranted = [
      status1,
      status2,
      status3,
    ].any((element) => element.isGranted);

    return isGranted;
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

  Future<PermissionStatus> initializeCurrentPermission() async {
    return await Permission.camera.status;
  }
}
