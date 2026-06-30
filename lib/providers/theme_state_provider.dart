import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/app_data.dart';
import '../core/models/theme_item.dart';

const String _kFavThemes = 'LS_FAV_THEMES';

class ThemeStateNotifier extends Notifier<List<ThemeItem>> {
  @override
  List<ThemeItem> build() {
    // Build sync state trước, rồi load favorites async
    Future.microtask(_loadFavorites);
    return kThemes.map((t) => ThemeItem(
      id: t.id,
      title: t.title,
      category: t.category,
      img: t.img,
      isPremium: t.isPremium,
    )).toList();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = (prefs.getStringList(_kFavThemes) ?? []).map(int.parse).toSet();
    if (favIds.isEmpty) return;
    state = [
      for (final t in state)
        if (favIds.contains(t.id))
          ThemeItem(id: t.id, title: t.title, category: t.category, img: t.img, isPremium: t.isPremium, isFavorite: true)
        else
          t,
    ];
  }

  void toggleFavorite(int id) {
    state = [
      for (final t in state)
        if (t.id == id)
          ThemeItem(
            id: t.id,
            title: t.title,
            category: t.category,
            img: t.img,
            isPremium: t.isPremium,
            isFavorite: !t.isFavorite,
          )
        else
          t,
    ];
    _persistFavorites();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = state.where((t) => t.isFavorite).map((t) => t.id.toString()).toList();
    await prefs.setStringList(_kFavThemes, favIds);
  }
}

final themeStateProvider =
    NotifierProvider<ThemeStateNotifier, List<ThemeItem>>(ThemeStateNotifier.new);

final selectedCategoryProvider = StateProvider<String>((ref) => 'ALL SYSTEM');
final favFilterActiveProvider = StateProvider<bool>((ref) => false);

final filteredThemesProvider = Provider<List<ThemeItem>>((ref) {
  final themes = ref.watch(themeStateProvider);
  final cat = ref.watch(selectedCategoryProvider);
  final favOnly = ref.watch(favFilterActiveProvider);

  return themes.where((t) {
    final catMatch = cat == 'ALL SYSTEM' || t.category == cat;
    final favMatch = !favOnly || t.isFavorite;
    return catMatch && favMatch;
  }).toList();
});
