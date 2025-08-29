// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:extra/main.dart';

void main() {
  // Inicializa DB FFI em ambientes desktop de teste
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  testWidgets('App smoke test: shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelExpensesApp());
    // First frame may be loading due to DB open; pump until settled
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Despesas da Viagem'), findsOneWidget);
  });
}
