import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kUnlockedStickers = 'LS_UNLOCKED';
const String _kUnlockedThemes = 'LS_UNLOCKED_THEMES';
const String _kPremium = 'LS_PREMIUM';

class EntitlementState {
  final Set<int> unlockedStickers;
  final Set<int> unlockedThemes;
  final bool isPremium;

  const EntitlementState({
    required this.unlockedStickers,
    required this.unlockedThemes,
    required this.isPremium,
  });

  EntitlementState copyWith({
    Set<int>? unlockedStickers,
    Set<int>? unlockedThemes,
    bool? isPremium,
  }) =>
      EntitlementState(
        unlockedStickers: unlockedStickers ?? this.unlockedStickers,
        unlockedThemes: unlockedThemes ?? this.unlockedThemes,
        isPremium: isPremium ?? this.isPremium,
      );

  bool isStickerUnlocked(int id) => unlockedStickers.contains(id) || isPremium;
  bool isThemeUnlocked(int id) => unlockedThemes.contains(id) || isPremium;
}

class EntitlementNotifier extends AsyncNotifier<EntitlementState> {
  late SharedPreferences _prefs;

  @override
  Future<EntitlementState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  EntitlementState _load() {
    final stickers = (_prefs.getStringList(_kUnlockedStickers) ?? [])
        .map(int.parse)
        .toSet();
    final themes = (_prefs.getStringList(_kUnlockedThemes) ?? [])
        .map(int.parse)
        .toSet();
    final premium = _prefs.getBool(_kPremium) ?? false;
    return EntitlementState(
      unlockedStickers: stickers,
      unlockedThemes: themes,
      isPremium: premium,
    );
  }

  Future<void> unlockSticker(int id) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final updated = {...s.unlockedStickers, id};
    await _prefs.setStringList(_kUnlockedStickers, updated.map((e) => e.toString()).toList());
    state = AsyncData(s.copyWith(unlockedStickers: updated));
  }

  Future<void> unlockTheme(int id) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final updated = {...s.unlockedThemes, id};
    await _prefs.setStringList(_kUnlockedThemes, updated.map((e) => e.toString()).toList());
    state = AsyncData(s.copyWith(unlockedThemes: updated));
  }

  Future<void> setPremium() async {
    await _prefs.setBool(_kPremium, true);
    final s = state.valueOrNull;
    if (s != null) state = AsyncData(s.copyWith(isPremium: true));
  }

  Future<void> revokePremium() async {
    await _prefs.setBool(_kPremium, false);
    final s = state.valueOrNull;
    if (s != null) state = AsyncData(s.copyWith(isPremium: false));
  }

  Future<void> togglePremium() async {
    final s = state.valueOrNull;
    if (s == null) return;
    final newVal = !s.isPremium;
    await _prefs.setBool(_kPremium, newVal);
    state = AsyncData(s.copyWith(isPremium: newVal));
  }
}

final entitlementProvider =
    AsyncNotifierProvider<EntitlementNotifier, EntitlementState>(
  EntitlementNotifier.new,
);
