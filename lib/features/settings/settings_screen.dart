import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/entitlement_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _adsEnabled;

  @override
  void initState() {
    super.initState();
    _adsEnabled = adService.adsEnabled;
  }

  Future<void> _toggleAds(bool value) async {
    await adService.setAdsEnabled(value);
    if (mounted) setState(() => _adsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      appBar: AppBar(
        backgroundColor: AppColors.bgCyber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
          onPressed: () => context.pop(),
        ),
        title: const Text('SETTINGS', style: TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron', fontSize: 14)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Premium toggle ---
          Consumer(builder: (_, r, __) {
            final isPremium = r.watch(entitlementProvider).valueOrNull?.isPremium ?? false;
            return _switchTile(
              icon: Icons.workspace_premium,
              label: 'PREMIUM',
              sub: isPremium
                  ? 'Đang bật — mở khóa tất cả theme & sticker'
                  : 'Đang tắt — cần xem ads để mở khóa',
              value: isPremium,
              onChanged: (_) => r.read(entitlementProvider.notifier).togglePremium(),
            );
          }),
          const Divider(color: AppColors.borderCyber),
          // --- Ads toggle ---
          _switchTile(
            icon: Icons.ads_click,
            label: 'QUẢNG CÁO',
            sub: _adsEnabled ? 'Đang bật — tắt để thoát ads' : 'Đang tắt — mọi ads bị bypass',
            value: _adsEnabled,
            onChanged: _toggleAds,
          ),
          const Divider(color: AppColors.borderCyber),
          _tile(
            icon: Icons.email_outlined,
            label: 'FEEDBACK',
            sub: 'Gửi phản hồi cho Studio',
            onTap: () async {
              final uri = Uri.parse('mailto:claudecell04@gmail.com?subject=DIY Wallpaper Feedback');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          _tile(
            icon: Icons.share,
            label: 'SHARE APP',
            sub: 'Chia sẻ app với bạn bè',
            onTap: () => Share.share(
              'Check out DIY Wallpaper! https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper',
            ),
          ),
          _tile(
            icon: Icons.star_outline,
            label: 'RATE APP',
            sub: '5 sao để ủng hộ Studio',
            onTap: () async {
              final review = InAppReview.instance;
              if (await review.isAvailable()) {
                await _showRateDialog(context, review);
              }
            },
          ),
          _tile(
            icon: Icons.privacy_tip_outlined,
            label: 'PRIVACY POLICY',
            sub: 'Chính sách quyền riêng tư',
            onTap: () {},
          ),
          const Divider(color: AppColors.borderCyber),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('DIY WALLPAPER', style: TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron', fontSize: 12)),
                SizedBox(height: 4),
                Text('Version 1.0.0 · VI', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.neonCyan),
      title: Text(label, style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 12)),
      subtitle: Text(sub, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
      value: value,
      activeColor: AppColors.neonCyan,
      onChanged: onChanged,
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonCyan),
      title: Text(label, style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 12)),
      subtitle: Text(sub, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Future<void> _showRateDialog(BuildContext context, InAppReview review) async {
    int stars = 0;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('RATE APP', style: TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron')),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => stars = i + 1),
              child: Icon(
                i < stars ? Icons.star : Icons.star_border,
                color: AppColors.neonYellow,
                size: 36,
              ),
            )),
          ),
          actions: [
            TextButton(
              onPressed: stars > 0 ? () async {
                Navigator.of(ctx).pop();
                await review.openStoreListing(appStoreId: 'com.studio.diy_wallpaper');
              } : null,
              child: Text('CONFIRM', style: TextStyle(
                color: stars > 0 ? AppColors.neonCyan : AppColors.textMuted,
                fontFamily: 'Orbitron',
              )),
            ),
          ],
        ),
      ),
    );
  }
}
