import 'dart:io';
import 'package:async_wallpaper/async_wallpaper.dart' as aw;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

const MethodChannel _pickerChannel = MethodChannel(AppConstants.wallpaperChannelName);

enum WallpaperTarget { home, lock, both }

class WallpaperService {
  static Future<bool> setWallpaper(String imagePath, WallpaperTarget target) async {
    final aw.WallpaperTarget awTarget = switch (target) {
      WallpaperTarget.home => aw.WallpaperTarget.home,
      WallpaperTarget.lock => aw.WallpaperTarget.lock,
      WallpaperTarget.both => aw.WallpaperTarget.both,
    };
    try {
      final String filePath;
      if (imagePath.startsWith('/')) {
        filePath = imagePath;
      } else {
        final bytes = await rootBundle.load(imagePath);
        final ext = imagePath.split('.').last;
        final tmp = File('${Directory.systemTemp.path}/wp_tmp.$ext');
        await tmp.writeAsBytes(bytes.buffer.asUint8List());
        filePath = tmp.path;
      }
      final result = await aw.AsyncWallpaper.setWallpaper(
        aw.WallpaperRequest(
          target: awTarget,
          sourceType: aw.WallpaperSourceType.file,
          source: filePath,
          goToHome: false,
        ),
      );
      debugPrint('[WallpaperService] Set $target: ${result.isSuccess}');
      return result.isSuccess;
    } catch (e) {
      debugPrint('[WallpaperService] Error: $e');
      return false;
    }
  }

  /// Mở system wallpaper picker với ảnh snapshot — không apply trong app.
  /// [imagePath]: file path tuyệt đối hoặc asset path.
  static Future<void> openSystemWallpaperPicker(String imagePath) async {
    String filePath;
    if (imagePath.startsWith('/')) {
      filePath = imagePath;
    } else {
      // Asset → extract ra cache dir (FileProvider-accessible)
      final bytes = await rootBundle.load(imagePath);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wp_picker_asset.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      filePath = file.path;
    }
    try {
      await _pickerChannel.invokeMethod('openWallpaperPicker', {'path': filePath});
    } catch (e) {
      debugPrint('[WallpaperService] openWallpaperPicker error: $e');
    }
  }

  /// Bật foreground service — treo notification cố định để MIUI không kill app
  /// khi system wallpaper picker activity mở ra (app chuyển sang background).
  static Future<void> startShield() async {
    if (!Platform.isAndroid) return;
    try {
      await _pickerChannel.invokeMethod('startWallpaperShield');
    } catch (e) {
      debugPrint('[WallpaperService] startShield error: $e');
    }
  }

  /// Tắt foreground service sau khi wallpaper đã set xong.
  static Future<void> stopShield() async {
    if (!Platform.isAndroid) return;
    try {
      await _pickerChannel.invokeMethod('stopWallpaperShield');
    } catch (e) {
      debugPrint('[WallpaperService] stopShield error: $e');
    }
  }
}
