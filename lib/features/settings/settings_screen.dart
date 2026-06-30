import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/banner_ad_widget.dart';
import '../../providers/entitlement_provider.dart';
import 'premium_modal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = ref.s;
    final langCode = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: BannerAdWidget(),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bgCyber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
          onPressed: () => context.pop(),
        ),
        title: Text(s.settingsTitle,
            style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron', fontSize: 14)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer(builder: (_, r, __) {
            final isPremium = r.watch(entitlementProvider).valueOrNull?.isPremium ?? false;
            final rs = r.watch(stringsProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _premiumTile(isPremium, rs),
                _switchTile(
                  icon: Icons.workspace_premium,
                  label: rs.premiumToggleLabel,
                  sub: isPremium ? rs.premiumOn : rs.premiumOff,
                  value: isPremium,
                  onChanged: (v) async {
                    if (v) {
                      await r.read(entitlementProvider.notifier).setPremium();
                    } else {
                      await r.read(entitlementProvider.notifier).revokePremium();
                    }
                  },
                ),
              ],
            );
          }),
          const Divider(color: AppColors.borderCyber),
          // Language selector
          _langTile(s, langCode),
          const Divider(color: AppColors.borderCyber),
          _tile(
            icon: Icons.email_outlined,
            label: s.feedbackLabel,
            sub: s.feedbackSub,
            onTap: () async {
              final uri = Uri.parse('mailto:claudecell04@gmail.com?subject=DIY Wallpaper Feedback');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          _tile(
            icon: Icons.share,
            label: s.shareAppLabel,
            sub: s.shareAppSub,
            onTap: () => SharePlus.instance.share(ShareParams(
              text: 'Check out DIY Wallpaper! https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper',
            )),
          ),
          _tile(
            icon: Icons.star_outline,
            label: s.rateAppLabel,
            sub: s.rateAppSub,
            onTap: () async {
              final review = InAppReview.instance;
              if (await review.isAvailable()) {
                await _showRateDialog(context, review, s);
              }
            },
          ),
          _tile(
            icon: Icons.privacy_tip_outlined,
            label: s.privacyPolicyLabel,
            sub: s.privacyPolicySub,
            onTap: () {},
          ),
          const Divider(color: AppColors.borderCyber),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(s.versionLabel,
                    style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron', fontSize: 12)),
                const SizedBox(height: 4),
                Text(s.versionSub(langCode),
                    style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langTile(s, String current) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.neonCyan),
      title: Text(s.languageLabel,
          style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 12)),
      subtitle: Text(s.languageSub,
          style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
      trailing: _LangToggle(current: current),
    );
  }

  Widget _premiumTile(bool isPremium, s) {
    return GestureDetector(
      onTap: isPremium ? null : () => PremiumModal.show(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [AppColors.bgCard, AppColors.bgCard]
                : [AppColors.bgCard, const Color(0xFF0D1F2D)],
          ),
          border: Border.all(
            color: isPremium ? AppColors.neonCyan : AppColors.borderCyber,
            width: isPremium ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => LinearGradient(
                colors: isPremium
                    ? [AppColors.neonCyan, AppColors.neonCyan]
                    : [AppColors.neonCyan, AppColors.neonPink],
              ).createShader(b),
              child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? s.premiumActiveLabel : s.buyPremiumLabel,
                    style: TextStyle(
                      color: isPremium ? AppColors.neonCyan : AppColors.textMain,
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPremium ? s.premiumBannerActiveSub : s.premiumBannerBuySub,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontFamily: 'Rajdhani',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium) const Icon(Icons.chevron_right, color: AppColors.neonCyan),
            if (isPremium) const Icon(Icons.verified, color: AppColors.neonCyan, size: 18),
          ],
        ),
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
      title: Text(label,
          style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 12)),
      subtitle: Text(sub,
          style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
      value: value,
      activeThumbColor: AppColors.neonCyan,
      activeTrackColor: AppColors.neonCyan.withOpacity(0.4),
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
      title: Text(label,
          style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 12)),
      subtitle: Text(sub,
          style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Future<void> _showRateDialog(BuildContext context, InAppReview review, s) async {
    int stars = 0;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Text(s.rateAppLabel,
              style: const TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron')),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (i) => GestureDetector(
                      onTap: () => setS(() => stars = i + 1),
                      child: Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: AppColors.neonYellow,
                        size: 36,
                      ),
                    )),
          ),
          actions: [
            TextButton(
              onPressed: stars > 0
                  ? () async {
                      Navigator.of(ctx).pop();
                      await review.openStoreListing(
                          appStoreId: 'com.studio.diy_wallpaper');
                    }
                  : null,
              child: Text(s.rateConfirm,
                  style: TextStyle(
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

class _LangToggle extends ConsumerWidget {
  final String current;
  const _LangToggle({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(context, ref, 'VI', current == 'vi'),
        const SizedBox(width: 6),
        _btn(context, ref, 'EN', current == 'en'),
      ],
    );
  }

  Widget _btn(BuildContext context, WidgetRef ref, String code, bool active) {
    return GestureDetector(
      onTap: active
          ? null
          : () => ref.read(localeProvider.notifier).setLocale(Locale(code.toLowerCase())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.neonCyan.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.neonCyan : AppColors.borderCyber,
          ),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: active ? AppColors.neonCyan : AppColors.textMuted,
            fontFamily: 'Orbitron',
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
