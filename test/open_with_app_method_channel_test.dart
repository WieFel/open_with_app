import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_with_app/open_with_app_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelOpenWithApp platform = MethodChannelOpenWithApp();
  const MethodChannel channel = MethodChannel('open_with_app/initial_file');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return 'test_file.txt';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getInitialFile', () async {
    expect(await platform.getInitialFile(), 'test_file.txt');
  });
}
