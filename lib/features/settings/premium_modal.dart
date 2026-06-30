import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/constants/analytics_events.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/iap_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../providers/entitlement_provider.dart';

class PremiumModal extends ConsumerStatefulWidget {
  const PremiumModal({super.key});

  static Future<void> show(BuildContext context, {String source = 'settings'}) {
    analyticsService.logIapPageViewed(source: source);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumModal(),
    );
  }

  @override
  ConsumerState<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends ConsumerState<PremiumModal> {
  bool _loading = false;
  ProductDetails? _product;

  @override
  void initState() {
    super.initState();
    iapService.init(
      onVerified: _onPurchaseVerified,
      onFailed: _onPurchaseFailed,
    );
    _loadProduct();
  }

  @override
  void dispose() {
    iapService.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final product = await iapService.fetchProduct();
    if (mounted) setState(() => _product = product);
  }

  Future<void> _onPurchaseVerified(PurchaseDetails details) async {
    await ref.read(entitlementProvider.notifier).setPremium();
    if (!mounted) return;
    analyticsService.logPurchase(
      productId: AppConstants.iapPremiumId,
      price: 29000,
      currency: 'VND',
      transactionId: details.purchaseID ?? 'unknown',
    );
    analyticsService.setUserType('premium');
    setState(() => _loading = false);
    Navigator.of(context).pop();
    CyberToast.show(context, ref.read(stringsProvider).premiumActivated);
  }

  void _onPurchaseFailed(String reason) {
    if (!mounted) return;
    if (reason != 'canceled') {
      analyticsService.logIapFailed(
        productId: AppConstants.iapPremiumId,
        errorCode: reason,
        errorMessage: reason,
      );
    }
    setState(() => _loading = false);
    if (reason != 'canceled') {
      CyberToast.show(context, ref.read(stringsProvider).purchaseFailed(reason),
          variant: ToastVariant.pink);
    }
  }

  Future<void> _purchase() async {
    analyticsService.logIapProductSelected(
      productId: AppConstants.iapPremiumId,
      price: 29000,
      currency: 'VND',
      productType: 'one_time',
    );
    setState(() => _loading = true);
    if (_product == null) {
      await _loadProduct();
      if (_product == null) {
        setState(() => _loading = false);
        CyberToast.show(context, ref.read(stringsProvider).storeUnavailable, variant: ToastVariant.pink);
        return;
      }
    }
    final ok = await iapService.buy(_product!);
    if (!ok && mounted) {
      setState(() => _loading = false);
      CyberToast.show(context, ref.read(stringsProvider).cannotOpenStore, variant: ToastVariant.pink);
    }
    // _onPurchaseVerified / _onPurchaseFailed handles the rest via stream
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    await iapService.restore();
    // Stream sẽ fire _onPurchaseVerified nếu tìm thấy purchase
    // Nếu không có gì → timeout sau 5s
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    final isPremium = ref.read(entitlementProvider).valueOrNull?.isPremium ?? false;
    if (!isPremium) {
      analyticsService.logIapFailed(
        productId: AppConstants.iapPremiumId,
        errorCode: 'not_found',
        errorMessage: 'No previous purchase found',
      );
      setState(() => _loading = false);
      CyberToast.show(context, ref.read(stringsProvider).noPurchaseFound, variant: ToastVariant.pink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(entitlementProvider).valueOrNull?.isPremium ?? false;
    final s = ref.watch(stringsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCyber,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        border: Border(top: BorderSide(color: AppColors.neonCyan, width: 1.5)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 3,
            color: AppColors.borderCyber,
            margin: const EdgeInsets.only(bottom: 24),
          ),

          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.neonCyan, AppColors.neonPink],
            ).createShader(bounds),
            child: Text(
              s.premiumTitle,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.premiumProSubtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontFamily: 'Rajdhani',
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 28),

          _BenefitRow(icon: Icons.block, text: s.premiumBenefit1),
          _BenefitRow(icon: Icons.image_outlined, text: s.premiumBenefit2),
          _BenefitRow(icon: Icons.auto_awesome, text: s.premiumBenefit3),
          _BenefitRow(icon: Icons.favorite_outline, text: s.premiumBenefit4),

          const SizedBox(height: 28),

          if (isPremium) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonCyan),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: AppColors.neonCyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    s.premiumAlreadyActive,
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              _product != null ? _product!.price : s.premiumLifetimePrice,
              style: const TextStyle(
                color: AppColors.neonYellow,
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const SizedBox(
                    height: 44,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonCyan,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : CyberButton(
                    label: s.buyNow,
                    fullWidth: true,
                    onTap: _purchase,
                  ),
            const SizedBox(height: 12),
            CyberButton(
              label: s.restorePurchase,
              fullWidth: true,
              variant: CyberButtonVariant.ghost,
              onTap: _loading ? null : _restore,
            ),
          ],
        ],
      ),
    );
  }
}


class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMain,
              fontFamily: 'Rajdhani',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
