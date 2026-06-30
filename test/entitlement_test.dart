import 'package:flutter_test/flutter_test.dart';
import 'package:diy_wallpaper/providers/entitlement_provider.dart';

void main() {
  group('EntitlementState', () {
    test('isStickerUnlocked returns false by default', () {
      const state = EntitlementState(
        unlockedStickers: {},
        unlockedThemes: {},
        isPremium: false,
      );
      expect(state.isStickerUnlocked(1), false);
    });

    test('isStickerUnlocked returns true after unlock', () {
      const state = EntitlementState(
        unlockedStickers: {1, 3, 5},
        unlockedThemes: {},
        isPremium: false,
      );
      expect(state.isStickerUnlocked(3), true);
      expect(state.isStickerUnlocked(2), false);
    });

    test('isThemeUnlocked returns true if premium', () {
      const state = EntitlementState(
        unlockedStickers: {},
        unlockedThemes: {},
        isPremium: true,
      );
      expect(state.isThemeUnlocked(99), true);
    });

    test('isThemeUnlocked returns true if theme explicitly unlocked', () {
      const state = EntitlementState(
        unlockedStickers: {},
        unlockedThemes: {4, 8},
        isPremium: false,
      );
      expect(state.isThemeUnlocked(4), true);
      expect(state.isThemeUnlocked(5), false);
    });

    test('copyWith preserves existing fields', () {
      const s = EntitlementState(
        unlockedStickers: {1},
        unlockedThemes: {4},
        isPremium: false,
      );
      final s2 = s.copyWith(isPremium: true);
      expect(s2.unlockedStickers, {1});
      expect(s2.unlockedThemes, {4});
      expect(s2.isPremium, true);
    });
  });
}
