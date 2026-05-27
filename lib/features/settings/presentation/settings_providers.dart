import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final initialSettingsProvider = Provider<AppSettings>(
  (_) => const AppSettings(),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.read(initialSettingsProvider);
  }

  Future<void> setCurrency(String currency) async {
    await ref.read(settingsRepositoryProvider).saveCurrency(currency);
    state = AppSettings(currency: currency, isDarkMode: state.isDarkMode);
  }

  Future<void> setDarkMode({required bool value}) async {
    await ref.read(settingsRepositoryProvider).saveDarkMode(isDarkMode: value);
    state = AppSettings(currency: state.currency, isDarkMode: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currency;
});
