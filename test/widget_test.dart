import 'package:flutter_test/flutter_test.dart';

import 'package:safepass/main.dart';

void main() {
  testWidgets(
    'La aplicación inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const PasswordVaultApp(),
      );

      expect(
        find.text('Password Vault'),
        findsOneWidget,
      );
    },
  );
}