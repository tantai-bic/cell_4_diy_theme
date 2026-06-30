import 'package:shared_preferences/shared_preferences.dart';

const pendingRestoreService = PendingRestoreService();

class PendingGarageApply {
  final String imagePath;
  final int? themeId;
  final List<String> stickersJson;

  const PendingGarageApply({
    required this.imagePath,
    this.themeId,
    required this.stickersJson,
  });
}

class PendingRestoreService {
  const PendingRestoreService();

  static const _kShareImage = 'pending_share_image';
  static const _kGarageThemeId = 'pending_garage_theme_id';
  static const _kGarageStickers = 'pending_garage_stickers';
  static const _kGalleryThemeId = 'pending_gallery_theme_id';

  Future<PendingGarageApply?> loadGarageApply() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_kShareImage);
    if (imagePath == null || imagePath.isEmpty) return null;
    return PendingGarageApply(
      imagePath: imagePath,
      themeId: prefs.getInt(_kGarageThemeId),
      stickersJson: prefs.getStringList(_kGarageStickers) ?? [],
    );
  }

  Future<void> saveGarageApply({
    required int themeId,
    required List<String> stickersJson,
    required String imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGarageThemeId, themeId);
    await prefs.setStringList(_kGarageStickers, stickersJson);
    await prefs.setString(_kShareImage, imagePath);
  }

  Future<void> clearGarageApply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kShareImage);
    await prefs.remove(_kGarageThemeId);
    await prefs.remove(_kGarageStickers);
  }

  Future<int?> loadGalleryThemeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kGalleryThemeId);
  }

  Future<void> saveGalleryApply({required int themeId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGalleryThemeId, themeId);
  }

  Future<void> clearGalleryApply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGalleryThemeId);
  }
}
