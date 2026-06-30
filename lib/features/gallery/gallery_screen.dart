import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../providers/entitlement_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/theme_state_provider.dart';
import '../../core/services/network_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../garage/reward_modal.dart';
import '../garage/set_wallpaper_modal.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../router/app_router.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  final int initialThemeId;

  const GalleryScreen({super.key, required this.initialThemeId});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  late PageController _pageCtrl;
  late int _currentIndex;
  late List<ThemeItem> _themes;
  late List<ThemeItem?> _feed; // null = native ad slot

  final Map<int, NativeAd> _nativeAds = {};
  final Map<int, bool> _nativeAdLoaded = {};

  // Insert a native ad slot every 5 themes (chỉ khi ads bật)
  static List<ThemeItem?> _buildFeed(List<ThemeItem> themes) {
    if (!adService.adsEnabled) return themes.cast<ThemeItem?>();
    final result = <ThemeItem?>[];
    for (var i = 0; i < themes.length; i++) {
      result.add(themes[i]);
      if ((i + 1) % 5 == 0 && i < themes.length - 1) result.add(null);
    }
    return result;
  }

  // Bắt đầu load ad khi user còn cách ad slot này nhiêu bước
  static const int _kAdLookahead = 6;

  void _loadNativeAdAt(int feedIndex) {
    if (_nativeAds.containsKey(feedIndex)) return;
    _nativeAdLoaded[feedIndex] = false;
    final ad = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.bgCard,
        cornerRadius: 0,
        callToActionTextStyle: NativeTemplateTextStyle(
          backgroundColor: AppColors.neonCyan,
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
        ),
        primaryTextStyle: NativeTemplateTextStyle(textColor: Colors.white),
        secondaryTextStyle: NativeTemplateTextStyle(textColor: AppColors.textMuted),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _nativeAdLoaded[feedIndex] = true);
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          _nativeAds.remove(feedIndex);
          _nativeAdLoaded.remove(feedIndex);
          debugPrint('[NativeAd] Failed feed[$feedIndex]: ${error.message}');
        },
      ),
    )..load();
    _nativeAds[feedIndex] = ad;
  }

  // Scan lookahead window và load bất kỳ ad slot nào chưa được load
  void _preloadAhead(int fromFeedIndex) {
    final end = (fromFeedIndex + _kAdLookahead).clamp(0, _feed.length - 1);
    for (var i = fromFeedIndex; i <= end; i++) {
      if (_feed[i] == null) _loadNativeAdAt(i);
    }
  }

  @override
  void initState() {
    super.initState();
    // Mirror đúng filter đang active ở S2 (category + fav)
    final selectedCat = ref.read(selectedCategoryProvider);
    final favOnly = ref.read(favFilterActiveProvider);
    final allThemes = ref.read(themeStateProvider); // có isFavorite state
    _themes = allThemes.where((t) {
      final catMatch = selectedCat == 'ALL SYSTEM' || t.category == selectedCat;
      final favMatch = !favOnly || t.isFavorite;
      return catMatch && favMatch;
    }).toList();
    _feed = _buildFeed(_themes);
    _currentIndex = _themes.indexWhere((t) => t.id == widget.initialThemeId);
    if (_currentIndex < 0) _currentIndex = 0;
    // Tìm trực tiếp vị trí trong feed — tránh tính toán sai khi ads bị tắt
    // (khi ads off, feed = themes[], không có slot null → adsBefore luôn = 0)
    final feedPage = _feed.indexWhere((item) => item?.id == widget.initialThemeId);
    final startPage = feedPage >= 0 ? feedPage : _currentIndex;
    _pageCtrl = PageController(initialPage: startPage);
    // Preload ad slots gần vị trí bắt đầu ngay từ initState
    // để AdWidget PlatformView kịp khởi tạo trước khi user swipe tới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAhead(startPage);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final ad in _nativeAds.values) ad.dispose();
    super.dispose();
  }

  ThemeItem get _current => _themes.isNotEmpty ? _themes[_currentIndex.clamp(0, _themes.length - 1)] : kThemes.first;

  void _onSwipe(int feedIndex) {
    // Load ad slot nào nằm trong cửa sổ lookahead ngay khi user move 1 bước
    _preloadAhead(feedIndex);

    final item = _feed[feedIndex];
    if (item == null) return; // ad slot — no theme change
    final net = ref.read(networkProvider).valueOrNull;
    if (!(net?.isOnline ?? true)) {
      showNoInternetModal(context, ref);
      return;
    }
    setState(() => _currentIndex = _themes.indexOf(item));
  }

  Future<void> _handleApply() async {
    final entitlement = ref.read(entitlementProvider).valueOrNull;
    if (entitlement == null) return;

    final theme = _current;
    final prefs = await SharedPreferences.getInstance();

    Future<void> _doApply() async {
      // Ghi flag TRƯỚC khi gọi modal — nếu MIUI kill trong setWallpaper(),
      // LoadingScreen đọc flag này để restore về Gallery đúng vị trí theme.
      await prefs.setInt('pending_gallery_theme_id', theme.id);

      bool _applied = false;
      await SetWallpaperModal.show(context,
          imagePath: theme.img,
          onSuccess: () {
            _applied = true;
            // setWallpaper() đã hoàn thành — xóa flag ngay, ở lại gallery.
            // Không show overlay vì sẽ block back button.
            prefs.remove('pending_gallery_theme_id');
          });

      // User cancel hoặc set thất bại → xóa flag
      if (!_applied) {
        await prefs.remove('pending_gallery_theme_id');
      }
    }

    if (theme.isPremium && !entitlement.isThemeUnlocked(theme.id)) {
      await RewardModal.show(
        context,
        rewardContext: RewardContext.unlockTheme,
        onRewarded: () async {
          await ref.read(entitlementProvider.notifier).unlockTheme(theme.id);
          if (mounted) await _doApply();
        },
      );
    } else {
      await _doApply();
    }
  }

  Future<void> _handleEnterGarage() async {
    final theme = _current;
    final entitlement = ref.read(entitlementProvider).valueOrNull;

    if (theme.isPremium && !(entitlement?.isThemeUnlocked(theme.id) ?? false)) {
      await RewardModal.show(
        context,
        rewardContext: RewardContext.unlockTheme,
        onRewarded: () async {
          await ref.read(entitlementProvider.notifier).unlockTheme(theme.id);
          if (mounted) {
            context.pushNamed('garage',
                pathParameters: {'themeId': theme.id.toString()},
                extra: const GarageArgs());
          }
        },
      );
    } else {
      context.pushNamed('garage',
          pathParameters: {'themeId': theme.id.toString()},
          extra: const GarageArgs());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themes = ref.watch(themeStateProvider);
    final entitlementState = ref.watch(entitlementProvider).valueOrNull;
    final theme = _current;

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      body: Stack(
        children: [
          // Empty state khi không có theme yêu thích
          if (_themes.isEmpty)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, color: AppColors.neonPink, size: 48),
                  SizedBox(height: 16),
                  Text('CHƯA CÓ YÊU THÍCH',
                      style: TextStyle(color: AppColors.textMuted, fontFamily: 'Orbitron', fontSize: 13)),
                ],
              ),
            ),

          // Full-screen swipeable gallery (theme + native ad slots)
          if (_themes.isNotEmpty)
          PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.horizontal,
            onPageChanged: _onSwipe,
            itemCount: _feed.length,
            itemBuilder: (_, i) {
              final item = _feed[i];
              if (item == null) {
                return _NativeAdCard(
                  ad: _nativeAds[i],
                  loaded: _nativeAdLoaded[i] ?? false,
                );
              }
              return Image.asset(
                item.img,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
                      ),
                      const Spacer(),
                      Text(
                        _themes.isEmpty ? '' : theme.title,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontFamily: 'Orbitron',
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      // Favorite toggle
                      if (!_themes.isEmpty)
                        Consumer(builder: (_, ref, __) {
                          final t = ref.watch(themeStateProvider).firstWhere(
                                (x) => x.id == theme.id,
                                orElse: () => theme,
                              );
                          return GestureDetector(
                            onTap: () {
                              ref.read(themeStateProvider.notifier).toggleFavorite(theme.id);
                              CyberToast.show(context,
                                  t.isFavorite ? 'REMOVED' : 'ADDED TO FAVORITES');
                            },
                            child: Icon(
                              t.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: t.isFavorite ? AppColors.neonPink : AppColors.textMuted,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bgAmoled.withOpacity(0.9)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: (theme.isPremium && !(entitlementState?.isThemeUnlocked(theme.id) ?? false))
                          ? '🔒 GARAGE'
                          : 'VÀO GARAGE',
                      variant: CyberButtonVariant.secondary,
                      onTap: _handleEnterGarage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CyberButton(
                      label: (theme.isPremium && !(entitlementState?.isThemeUnlocked(theme.id) ?? false))
                          ? '🔒 ÁP DỤNG'
                          : 'ÁP DỤNG',
                      onTap: _handleApply,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Native ad placeholder (E3)
          // Injected as card in the page view feed via index modulo logic
        ],
      ),
    );
  }
}

class _NativeAdCard extends StatefulWidget {
  final NativeAd? ad;
  final bool loaded;

  const _NativeAdCard({this.ad, this.loaded = false});

  @override
  State<_NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<_NativeAdCard>
    with AutomaticKeepAliveClientMixin {
  // Giữ trang native ad sống sau khi đã render — tránh PlatformView init lại
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return Container(
      color: AppColors.bgAmoled,
      child: widget.loaded && widget.ad != null
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 350),
                child: AdWidget(ad: widget.ad!),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: AppColors.neonCyan),
            ),
    );
  }
}

