import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:no_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('flavored Android shell opens and navigates four tabs', (
    tester,
  ) async {
    expect(appFlavor, anyOf('dev', 'staging'));
    app.main();
    await tester.pumpAndSettle();
    for (final route in ['today', 'library', 'practice', 'garden']) {
      await tester.tap(find.byKey(ValueKey('tab/$route')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('/$route')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('/today')), findsOneWidget);
  });
}
