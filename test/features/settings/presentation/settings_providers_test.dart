import 'package:expense_tracker/features/settings/data/settings_repository.dart';
import 'package:expense_tracker/features/settings/domain/app_settings.dart';
import 'package:expense_tracker/features/settings/presentation/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  group('SettingsNotifier', () {
    late MockSettingsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockSettingsRepository();
    });

    tearDown(() => container.dispose());

    ProviderContainer createContainer({
      AppSettings initial = const AppSettings(),
    }) {
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(mockRepo),
          initialSettingsProvider.overrideWithValue(initial),
        ],
      );
      return container;
    }

    test('initial state is default AppSettings', () {
      createContainer();

      final settings = container.read(settingsProvider);
      expect(settings.currency, 'USD');
      expect(settings.isDarkMode, false);
    });

    test('uses preloaded initial settings', () {
      createContainer(
        initial: const AppSettings(currency: 'EUR', isDarkMode: true),
      );

      final settings = container.read(settingsProvider);
      expect(settings.currency, 'EUR');
      expect(settings.isDarkMode, true);
    });

    test('setCurrency persists and updates state', () async {
      when(() => mockRepo.saveCurrency(any())).thenAnswer((_) async {});

      createContainer();

      await container.read(settingsProvider.notifier).setCurrency('GBP');

      final settings = container.read(settingsProvider);
      expect(settings.currency, 'GBP');
      verify(() => mockRepo.saveCurrency('GBP')).called(1);
    });

    test('setDarkMode persists and updates state', () async {
      when(
        () => mockRepo.saveDarkMode(isDarkMode: any(named: 'isDarkMode')),
      ).thenAnswer((_) async {});

      createContainer();

      await container.read(settingsProvider.notifier).setDarkMode(value: true);

      final settings = container.read(settingsProvider);
      expect(settings.isDarkMode, true);
      verify(() => mockRepo.saveDarkMode(isDarkMode: true)).called(1);
    });

    test('setCurrency preserves dark mode setting', () async {
      when(() => mockRepo.saveCurrency(any())).thenAnswer((_) async {});
      when(
        () => mockRepo.saveDarkMode(isDarkMode: any(named: 'isDarkMode')),
      ).thenAnswer((_) async {});

      createContainer();

      await container.read(settingsProvider.notifier).setDarkMode(value: true);
      await container.read(settingsProvider.notifier).setCurrency('JPY');

      final settings = container.read(settingsProvider);
      expect(settings.currency, 'JPY');
      expect(settings.isDarkMode, true);
    });
  });

  group('currencyProvider', () {
    test('derives currency from settings', () {
      final container = ProviderContainer(
        overrides: [
          initialSettingsProvider.overrideWithValue(
            const AppSettings(currency: 'GBP'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currencyProvider), 'GBP');
    });
  });
}
