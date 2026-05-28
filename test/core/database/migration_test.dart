import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Future<bool> _hasDateIndex(AppDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT name FROM sqlite_master '
        "WHERE type = 'index' AND name = 'idx_expenses_date'",
      )
      .get();
  return rows.isNotEmpty;
}

void main() {
  test('a freshly created database has the expenses date index', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.customStatement('SELECT 1'); // force the database open

    expect(await _hasDateIndex(db), isTrue);
  });

  test('upgrading from schema v1 creates the expenses date index', () async {
    final dir = await Directory.systemTemp.createTemp('drift_migration_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File(p.join(dir.path, 'app.db'));

    // First open builds the current (v2) schema, including the index.
    final created = AppDatabase.forTesting(NativeDatabase(file));
    await created.customStatement('SELECT 1');
    // Roll the database back to a v1 state: drop the index, reset the version.
    await created.customStatement('DROP INDEX idx_expenses_date');
    await created.customStatement('PRAGMA user_version = 1');
    expect(await _hasDateIndex(created), isFalse);
    await created.close();

    // Reopening triggers onUpgrade(1 -> 2), which must recreate the index.
    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(migrated.close);
    await migrated.customStatement('SELECT 1');

    expect(await _hasDateIndex(migrated), isTrue);
  });
}
