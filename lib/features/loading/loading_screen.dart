import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/app_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../providers/network_provider.dart';
import '../../core/services/network_guard.dart';
import '../../router/app_router.dart';

enum _LoadState { detecting, modalLoading, fullSplash }

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _glitchCtrl;
  late AnimationController _scanCtrl;
  late Animation<double> _scan;

  _LoadState _state = _LoadState.detecting;

  @override
  void initState() {
    super.initState();
    // Tạo controller nhưng KHÔNG repeat — chỉ bật khi xác nhận first launch
    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scan = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // PRIORITY 1: MIUI restart sau khi set wallpaper từ garage
    // → không show splash, hiện modal "SYSTEM APPLYING..." rồi vào Share
    final pendingShareImage = prefs.getString('pending_share_image');
    if (pendingShareImage != null && pendingShareImage.isNotEmpty) {
      await prefs.remove('pending_share_image');
      if (!mounted) return;

      setState(() => _state = _LoadState.modalLoading);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      LoadingModal.hide();
      LoadingModal.show(context, messageBuilder: (s) => s.systemApplying);
      await Future.delayed(const Duration(milliseconds: 1200));

      LoadingModal.hide();
      if (mounted) {
        final themeId = prefs.getInt('pending_garage_theme_id');
        final stickersJson = prefs.getStringList('pending_garage_stickers') ?? [];
        final themeTitle = themeId != null
            ? kThemes.firstWhere((t) => t.id == themeId, orElse: () => kThemes.first).title
            : '';
        context.goNamed('share', extra: ShareArgs(
          imagePath: pendingShareImage,
          backContext: WallpaperSetContext.garage,
          themeTitle: themeTitle,
          stickerLayersJson: stickersJson,
          themeId: themeId ?? 1,
        ));
      }
      return;
    }

    // PRIORITY 2: MIUI restart sau khi set wallpaper từ gallery
    // → modal "SYSTEM APPLYING..." → restore Gallery đúng vị trí theme
    final pendingGalleryThemeId = prefs.getInt('pending_gallery_theme_id');
    if (pendingGalleryThemeId != null) {
      await prefs.remove('pending_gallery_theme_id');
      if (!mounted) return;

      setState(() => _state = _LoadState.modalLoading);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      LoadingModal.hide();
      LoadingModal.show(context, messageBuilder: (s) => s.systemApplying);
      await Future.delayed(const Duration(milliseconds: 1200));

      LoadingModal.hide();
      if (mounted) {
        context.goNamed('gallery',
            pathParameters: {'themeId': pendingGalleryThemeId.toString()});
      }
      return;
    }

    // PRIORITY 3: Mọi trường hợp còn lại → show splash rồi về home
    _glitchCtrl.repeat(reverse: true);
    _scanCtrl.repeat();
    if (mounted) setState(() => _state = _LoadState.fullSplash);

    final launchedBefore = prefs.getBool('app_launched_before') ?? false;
    if (!launchedBefore) {
      // First launch: 3-second splash + network check
      final splashStart = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final net = ref.read(networkProvider).valueOrNull;
      if (net != null && !net.isOnline) {
        await showNoInternetModal(context, ref);
      }
      // Đảm bảo tối thiểu 3s kể từ khi splash bắt đầu
      final elapsed = DateTime.now().difference(splashStart).inMilliseconds;
      final remaining = 3000 - elapsed;
      if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));
      await prefs.setBool('app_launched_before', true);
    } else {
      // Subsequent launches: splash 1.8s
      await Future.delayed(const Duration(milliseconds: 1800));
    }

    if (mounted) context.goNamed('home');
  }

  @override
  void dispose() {
    LoadingModal.hide(); // cleanup nếu navigate xảy ra sớm hơn dự kiến
    _glitchCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Black screen cho cả detecting và modalLoading
    // (modalLoading có LoadingModal overlay đè lên — không cần widget riêng)
    if (_state != _LoadState.fullSplash) {
      return const Scaffold(backgroundColor: AppColors.bgAmoled, body: SizedBox.shrink());
    }

    // First launch → full glitch splash
    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      body: Stack(
        children: [
          // Matrix scan line
          AnimatedBuilder(
            animation: _scan,
            builder: (_, __) => Positioned(
              top: MediaQuery.of(context).size.height * _scan.value - 2,
              left: 0,
              right: 0,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.neonCyan.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: AppTheme.neonGlow(AppColors.neonCyan, blur: 6),
                ),
              ),
            ),
          ),

          // Centered wordmark
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _glitchCtrl,
                  builder: (_, __) {
                    final offset = _glitchCtrl.value > 0.5 ? 2.0 : 0.0;
                    return Stack(
                      children: [
                        Transform.translate(
                          offset: Offset(-offset, 0),
                          child: const Text(
                            'DIY WALLPAPER',
                            style: TextStyle(
                              color: AppColors.neonPink,
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(offset, 0),
                          child: const Text(
                            'DIY WALLPAPER',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const Text(
                          'DIY WALLPAPER',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Orbitron',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  ref.watch(stringsProvider).splashSubtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // Bottom status
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.borderCyber,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.watch(stringsProvider).splashInitializing,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
