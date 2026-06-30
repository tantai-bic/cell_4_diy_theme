import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/theme_item.dart';

const String _kWallpaperBox = 'wallpapers';
const String _kDraftBox = 'drafts';

class LibraryState {
  final List<LibraryWallpaper> wallpapers;
  final List<LibraryDraft> drafts;

  const LibraryState({required this.wallpapers, required this.drafts});

  LibraryState copyWith({
    List<LibraryWallpaper>? wallpapers,
    List<LibraryDraft>? drafts,
  }) =>
      LibraryState(
        wallpapers: wallpapers ?? this.wallpapers,
        drafts: drafts ?? this.drafts,
      );
}

class LibraryNotifier extends AsyncNotifier<LibraryState> {
  late Box<LibraryWallpaper> _wallpaperBox;
  late Box<LibraryDraft> _draftBox;

  @override
  Future<LibraryState> build() async {
    _wallpaperBox = await Hive.openBox<LibraryWallpaper>(_kWallpaperBox);
    _draftBox = await Hive.openBox<LibraryDraft>(_kDraftBox);
    return _load();
  }

  LibraryState _load() => LibraryState(
        wallpapers: _wallpaperBox.values.toList().reversed.toList(),
        drafts: _draftBox.values.toList().reversed.toList(),
      );

  Future<void> saveWallpaper(LibraryWallpaper wall) async {
    await future; // đảm bảo build() xong trước khi dùng _wallpaperBox
    await _wallpaperBox.add(wall);
    state = AsyncData(_load());
  }

  Future<void> saveDraft(LibraryDraft draft) async {
    await future; // đảm bảo build() xong trước khi dùng _draftBox
    await _draftBox.add(draft);
    state = AsyncData(_load());
  }

  Future<void> deleteWallpapers(List<int> keys) async {
    await future;
    await _wallpaperBox.deleteAll(keys);
    state = AsyncData(_load());
  }

  Future<void> deleteDrafts(List<int> keys) async {
    await future;
    await _draftBox.deleteAll(keys);
    state = AsyncData(_load());
  }
}

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);
