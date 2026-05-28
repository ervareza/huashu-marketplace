import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/main.dart';

void main() {
  testWidgets('Session check smoke test', (WidgetTester tester) async {
    // Bangun aplikasi dan picu satu frame.
    await tester.pumpWidget(const MyApp());

    // Memverifikasi adanya indikator loading sesi saat awal pemuatan.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
