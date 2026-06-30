import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../providers/entitlement_provider.dart';
import '../../providers/theme_state_provider.dart';
import 'miui_guide_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Hiển thị MIUI guide một lần duy nhất nếu đang chạy trên MIUI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showMiuiGuideIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredThemes = ref.watch(filteredThemesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final favActive = ref.watch(favFilterActiveProvider);

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _CategoryScroll(selectedCat: selectedCat, favActive: favActive, ref: ref),
            Expanded(
              child: filteredThemes.isEmpty
                  ? _EmptyState(favActive: favActive, s: ref.watch(stringsProvider))
                  : _ThemeGrid(themes: filteredThemes),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'DIY WALLPAPER',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: AppColors.neonCyan),
            onPressed: () => context.pushNamed('library'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
    );
  }
}

class _CategoryScroll extends StatelessWidget {
  final String selectedCat;
  final bool favActive;
  final WidgetRef ref;

  const _CategoryScroll({
    required this.selectedCat,
    required this.favActive,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Fav filter chip
          _chip(
            context,
            label: ref.watch(stringsProvider).favorites,
            active: favActive,
            onTap: () {
                if (!favActive) {
                  ref.read(selectedCategoryProvider.notifier).state = 'ALL SYSTEM';
                }
                ref.read(favFilterActiveProvider.notifier).state = !favActive;
              },
            activeColor: AppColors.neonPink,
          ),
          ...kCategories.map((cat) => _chip(
                context,
                label: cat,
                active: selectedCat == cat && !favActive,
                onTap: () {
                  ref.read(favFilterActiveProvider.notifier).state = false;
                  ref.read(selectedCategoryProvider.notifier).state = cat;
                },
              )),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.neonCyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: active ? color : AppColors.borderCyber),
          borderRadius: BorderRadius.circular(2),
          boxShadow: active ? AppTheme.neonGlow(color, blur: 6) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : AppColors.textMuted,
            fontFamily: 'Orbitron',
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ThemeGrid extends ConsumerWidget {
  final List<ThemeItem> themes;
  const _ThemeGrid({required this.themes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Thêm bottom inset từ MediaQuery để items cuối không bị cắt
    // bởi gesture navigation bar (SafeArea trên Column đã xử lý hard constraint,
    // nhưng cần thêm padding nội dung để scroll comfortably)
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 9 / 16,
      ),
      itemCount: themes.length,
      itemBuilder: (_, i) => _ThemeCard(theme: themes[i], index: i),
    );
  }
}

class _ThemeCard extends ConsumerWidget {
  final ThemeItem theme;
  final int index;
  const _ThemeCard({required this.theme, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider).valueOrNull;
    final isLocked = theme.isPremium && !(entitlement?.isThemeUnlocked(theme.id) ?? false);
    return GestureDetector(
      onTap: () {
        analyticsService.logThemeCardClicked(
          themeId: theme.id.toString(),
          themeName: theme.title,
          isPremium: theme.isPremium,
          positionIndex: index,
          category: theme.category,
        );
        context.pushNamed('gallery', pathParameters: {'themeId': theme.id.toString()});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(theme.img, fit: BoxFit.cover),
          // Dark overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bgAmoled.withOpacity(0.85)],
                ),
              ),
              child: Text(
                theme.title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          // Lock badge — chỉ hiện khi theme bị khóa (chưa unlock)
          if (isLocked)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: AppColors.neonPink.withOpacity(0.85),
                child: const Icon(Icons.lock, color: Colors.white, size: 10),
              ),
            ),
          // Favorite button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                final s = ref.read(stringsProvider);
                ref.read(themeStateProvider.notifier).toggleFavorite(theme.id);
                CyberToast.show(
                  context,
                  theme.isFavorite ? s.removedFromFavorites : s.addedToFavorites,
                  variant: theme.isFavorite ? ToastVariant.normal : ToastVariant.pink,
                );
              },
              child: Icon(
                theme.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: theme.isFavorite ? AppColors.neonPink : AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool favActive;
  final dynamic s;
  const _EmptyState({required this.favActive, required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            favActive ? s.noFavorites : s.noResults,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontFamily: 'Orbitron',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
