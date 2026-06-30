import 'dart:convert';
import 'package:hive/hive.dart';
import '../../features/garage/sticker_layer.dart';

part 'theme_item.g.dart';

class ThemeItem {
  final int id;
  final String title;
  final String category;
  final String img;
  final bool isPremium;
  bool isFavorite;

  ThemeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.img,
    required this.isPremium,
    this.isFavorite = false,
  });
}

@HiveType(typeId: 0)
class LibraryWallpaper extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final bool isUnlocked;

  @HiveField(4)
  final DateTime savedAt;

  @HiveField(5)
  final String? snapshotPath;

  @HiveField(6)
  final List<String> stickerLayersJson;

  @HiveField(7)
  final int? themeId;

  LibraryWallpaper({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.isUnlocked,
    required this.savedAt,
    this.snapshotPath,
    this.stickerLayersJson = const [],
    this.themeId,
  });

  List<StickerLayer> get stickerLayers => stickerLayersJson
      .map((j) => StickerLayer.fromJson(jsonDecode(j) as Map<String, dynamic>))
      .toList();
}

@HiveType(typeId: 1)
class LibraryDraft extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String backgroundImg;

  @HiveField(3)
  final List<String> stickerPaths; // kept for backward compat

  @HiveField(4)
  final DateTime savedAt;

  @HiveField(5)
  final String? snapshotPath; // captured canvas PNG (background + stickers)

  @HiveField(6)
  final List<String> stickerLayersJson; // JSON-encoded StickerLayer list with x/y/scale

  LibraryDraft({
    required this.id,
    required this.title,
    required this.backgroundImg,
    required this.stickerPaths,
    required this.savedAt,
    this.snapshotPath,
    this.stickerLayersJson = const [],
  });

  /// Decode stored JSON back to StickerLayer list (with positions + scale).
  List<StickerLayer> get stickerLayers => stickerLayersJson
      .map((j) => StickerLayer.fromJson(jsonDecode(j) as Map<String, dynamic>))
      .toList();
}
