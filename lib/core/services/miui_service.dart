import 'dart:io';
import 'package:flutter/services.dart';

class MiuiService {
  static const _channel = MethodChannel('com.studio.diy_wallpaper/wallpaper');

  static Future<bool> isMiui() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isMiui') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mở MIUI Autostart Management (fallback: app settings)
  static Future<void> openAutostartSettings() async {
    try {
      await _channel.invokeMethod('openMiuiAutostart');
    } catch (_) {}
  }

  /// Mở MIUI Battery/Power settings cho app (fallback: REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
  static Future<void> openBatterySettings() async {
    try {
      await _channel.invokeMethod('openMiuiBatterySettings');
    } catch (_) {}
  }
}
