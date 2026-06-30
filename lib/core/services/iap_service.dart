import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

const kPremiumProductId = 'com.studio.diy_wallpaper.premium';

class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  void Function(PurchaseDetails)? _onVerified;
  void Function(String)? _onFailed;

  Future<void> init({
    required void Function(PurchaseDetails) onVerified,
    required void Function(String) onFailed,
  }) async {
    _onVerified = onVerified;
    _onFailed = onFailed;
    _sub?.cancel();
    _sub = _iap.purchaseStream.listen(_handleUpdates);
  }

  void dispose() {
    _sub?.cancel();
    _onVerified = null;
    _onFailed = null;
  }

  void _handleUpdates(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _iap.completePurchase(p);
          _onVerified?.call(p);
        case PurchaseStatus.error:
          _onFailed?.call(p.error?.message ?? 'unknown_error');
        case PurchaseStatus.canceled:
          _onFailed?.call('canceled');
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<ProductDetails?> fetchProduct() async {
    final available = await _iap.isAvailable();
    if (!available) return null;
    final res = await _iap.queryProductDetails({kPremiumProductId});
    if (res.notFoundIDs.isNotEmpty || res.productDetails.isEmpty) return null;
    return res.productDetails.first;
  }

  Future<bool> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() => _iap.restorePurchases();
}

final iapService = IapService.instance;
