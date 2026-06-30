import 'dart:io';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class MiuiService {
  static const _channel = MethodChannel(AppConstants.wallpaperChannelName);

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
