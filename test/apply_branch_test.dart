import 'package:flutter_test/flutter_test.dart';
import 'package:diy_wallpaper/providers/entitlement_provider.dart';

// Test apply-branch logic:
// - S3 Free theme: no ads (pass-through)
// - S3 Premium theme NOT unlocked: reward ad required
// - S3 Premium theme unlocked: no ads
// - S4 (Garage apply): ALWAYS reward ad regardless of free/premium
// - Library apply: ALWAYS free (no ads)

enum ApplySource { gallery, garage, library }

bool requiresAd({
  required ApplySource source,
  required bool isPremium,
  required bool isUnlocked,
}) {
  return switch (source) {
    ApplySource.garage => true,           // AC3: ALWAYS ads from garage
    ApplySource.library => false,         // AC10: always free from library
    ApplySource.gallery =>
      isPremium && !isUnlocked,          // AC2: free theme = no ads; premium+locked = ads
  };
}

void main() {
  group('Apply branch logic', () {
    test('S3 free theme: no ads', () {
      expect(requiresAd(source: ApplySource.gallery, isPremium: false, isUnlocked: false), false);
    });

    test('S3 premium+locked: ads required', () {
      expect(requiresAd(source: ApplySource.gallery, isPremium: true, isUnlocked: false), true);
    });

    test('S3 premium+unlocked: no ads', () {
      expect(requiresAd(source: ApplySource.gallery, isPremium: true, isUnlocked: true), false);
    });

    test('S4 (garage) free theme: ALWAYS ads', () {
      expect(requiresAd(source: ApplySource.garage, isPremium: false, isUnlocked: false), true);
    });

    test('S4 (garage) premium theme: ALWAYS ads', () {
      expect(requiresAd(source: ApplySource.garage, isPremium: true, isUnlocked: true), true);
    });

    test('Library apply: NEVER ads', () {
      expect(requiresAd(source: ApplySource.library, isPremium: true, isUnlocked: false), false);
    });
  });

  group('EntitlementState — unlock persist', () {
    test('theme unlock persists in copyWith', () {
      var state = const EntitlementState(
        unlockedStickers: {},
        unlockedThemes: {},
        isPremium: false,
      );
      state = state.copyWith(unlockedThemes: {4});
      expect(state.isThemeUnlocked(4), true);
      expect(requiresAd(source: ApplySource.gallery, isPremium: true, isUnlocked: state.isThemeUnlocked(4)), false);
    });
  });
}
