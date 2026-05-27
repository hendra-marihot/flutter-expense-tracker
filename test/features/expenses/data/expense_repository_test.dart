import 'package:expense_tracker/features/expenses/data/expense_local_data_source.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseLocalDataSource extends Mock
    implements ExpenseLocalDataSource {}

class FakeExpense extends Fake implements Expense {}

void main() {
  late MockExpenseLocalDataSource mockDataSource;
  late ExpenseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeExpense());
  });

  setUp(() {
    mockDataSource = MockExpenseLocalDataSource();
    repository = ExpenseRepositoryImpl(mockDataSource);
  });

  final testExpense = Expense(
    id: 'test-1',
    title: 'Lunch',
    amount: 12.50,
    category: ExpenseCategory.food,
    date: DateTime(2025, 5, 15),
    createdAt: DateTime(2025, 5, 15),
  );

  group('watchAllExpenses', () {
    test('delegates to data source', () {
      when(
        () => mockDataSource.watchAllExpenses(),
      ).thenAnswer((_) => Stream.value([testExpense]));

      final stream = repository.watchAllExpenses();
      expect(stream, emits([testExpense]));
    });

    test('emits empty list when no expenses', () {
      when(
        () => mockDataSource.watchAllExpenses(),
      ).thenAnswer((_) => Stream.value([]));

      final stream = repository.watchAllExpenses();
      expect(stream, emits(isEmpty));
    });
  });

  group('watchExpensesByMonth', () {
    test('passes year and month to data source', () {
      when(
        () => mockDataSource.watchExpensesByMonth(2025, 5),
      ).thenAnswer((_) => Stream.value([testExpense]));

      final stream = repository.watchExpensesByMonth(2025, 5);
      expect(stream, emits([testExpense]));
      verify(() => mockDataSource.watchExpensesByMonth(2025, 5)).called(1);
    });
  });

  group('addExpense', () {
    test('delegates insert to data source', () async {
      when(() => mockDataSource.insertExpense(any())).thenAnswer((_) async {});

      await repository.addExpense(testExpense);
      verify(() => mockDataSource.insertExpense(testExpense)).called(1);
    });
  });

  group('deleteExpense', () {
    test('delegates delete to data source', () async {
      when(() => mockDataSource.deleteExpense(any())).thenAnswer((_) async {});

      await repository.deleteExpense('test-1');
      verify(() => mockDataSource.deleteExpense('test-1')).called(1);
    });
  });
}
