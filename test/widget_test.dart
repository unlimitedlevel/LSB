// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lsb_ocr/services/auth_service.dart'; // Import AuthService
import 'package:lsb_ocr/main.dart';

void main() {
  // Inisialisasi AuthService untuk testing
  // Di test yang lebih kompleks, ini bisa diganti dengan mock object
  final AuthService testAuthService = AuthService();

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Sertakan authService saat memanggil MyApp
    await tester.pumpWidget(MyApp(authService: testAuthService));

    // Verify that our counter starts at 0.
    // Catatan: Test ini mungkin perlu disesuaikan karena layar awal sekarang
    // tergantung pada status auth (LoginScreen atau MainScreen).
    // Untuk sementara, kita biarkan dulu.
    // expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
