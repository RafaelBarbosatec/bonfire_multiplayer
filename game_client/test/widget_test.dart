// Smoke test: the app boots and shows the login screen.

import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => BootstrapInjector.run());

  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
