import 'package:flutter_test/flutter_test.dart';
import 'package:open_with_app/open_with_app.dart';
import 'package:open_with_app/open_with_app_platform_interface.dart';
import 'package:open_with_app/open_with_app_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOpenWithAppPlatform
    with MockPlatformInterfaceMixin
    implements OpenWithAppPlatform {

  @override
  Future<String?> getInitialFile() => Future.value('test_file.txt');
  
  @override
  Stream<String> getFileStream() => const Stream.empty();
}

void main() {
  final OpenWithAppPlatform initialPlatform = OpenWithAppPlatform.instance;

  test('$MethodChannelOpenWithApp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOpenWithApp>());
  });

  test('getInitialFile', () async {
    OpenWithApp openWithAppPlugin = OpenWithApp();
    MockOpenWithAppPlatform fakePlatform = MockOpenWithAppPlatform();
    OpenWithAppPlatform.instance = fakePlatform;

    expect(await openWithAppPlugin.getInitialFile(), 'test_file.txt');
  });
}
