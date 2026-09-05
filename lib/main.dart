import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedSettings = await SettingsRepository().load();
  runApp(
    ProviderScope(
      overrides: [initialSettingsProvider.overrideWithValue(savedSettings)],
      child: const ExpenseTrackerApp(),
    ),
  );
}
