import 'package:flutter_test/flutter_test.dart';

import 'package:aeroyield/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroYieldApp());

    // Async localization delegates need an extra frame to finish loading.
    await tester.pump();

    // The splash screen should display the app name
    expect(find.text('AeroYield'), findsOneWidget);
  });
}
