import 'dart:ui';

import 'package:image_provider/image_provider.dart';

DeviceType getDeviceType() {
  final display = PlatformDispatcher.instance.views.first.display;
  final value = display.size.shortestSide / display.devicePixelRatio < 550;
  return value ? DeviceType.phone : DeviceType.tablet;
}
