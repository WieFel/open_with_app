// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:open_with_app/open_with_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getInitialFile test', (WidgetTester tester) async {
    final OpenWithApp plugin = OpenWithApp();
    final String? initialFile = await plugin.getInitialFile();
    // In a clean integration test run without opening a file, this should be null.
    // This primarily tests that the method channel call works without error.
    expect(initialFile, null);
  });
}
