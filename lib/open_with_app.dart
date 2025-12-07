import 'open_with_app_platform_interface.dart';

class OpenWithApp {
  Future<String?> getInitialFile() {
    return OpenWithAppPlatform.instance.getInitialFile();
  }

  Stream<String> getFileStream() {
    return OpenWithAppPlatform.instance.getFileStream();
  }
}
