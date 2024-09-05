import 'package:permission_handler/permission_handler.dart';

class PermissionData {
  final String name;
  Permission permission;
  bool granted = false;

  PermissionData({required this.name, required this.permission}) {
    foo();
  }

  void foo() async {
    granted = await permission.status.isGranted;
  }

  Future<bool> requestPermission() async {
    granted = await permission.request().isGranted;
    return granted;
  }

  Future<bool> get request async => await requestPermission();
  Future<bool> get impossible async => await permission.isPermanentlyDenied || await permission.isRestricted;
}
