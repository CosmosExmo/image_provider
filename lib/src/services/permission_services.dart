import 'package:permission_manager/permission_manager.dart';

class PermissionServices {
  final permissionManager = PermissionManager();
  Future<bool> getStorageRequest() async {
    final response = await permissionManager.requestMedia(photos: true);

    return response.isAllGranted;
  }

  Future<bool> getCameraRequest() async {
    final response = await permissionManager.requestCamera();

    return response.isAllGranted;
  }

  Future<PermissionStatus> initializeCurrentPermission() async =>
      await permissionManager.cameraStatus();
}
