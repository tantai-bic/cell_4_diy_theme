import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

const _kLangKey = 'app_lang';

/// Trả về ngôn ngữ mặc định dựa trên locale của điện thoại:
/// 'vi' nếu device là tiếng Việt, 'en' cho mọi ngôn ngữ khác.
String _deviceDefaultLang() {
  final systemLang = PlatformDispatcher.instance.locale.languageCode;
  return systemLang == 'vi' ? 'vi' : 'en';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale(_deviceDefaultLang())) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Nếu user đã chọn ngôn ngữ trước → dùng lại.
    // Lần đầu cài app (chưa có key) → theo ngôn ngữ điện thoại.
    final saved = prefs.getString(_kLangKey);
    final lang = saved ?? _deviceDefaultLang();
    state = Locale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, locale.languageCode);
  }
}

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings.of(locale.languageCode);
});

extension RefStrings on WidgetRef {
  AppStrings get s => watch(stringsProvider);
}
