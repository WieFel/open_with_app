import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'open_with_app_method_channel.dart';

abstract class OpenWithAppPlatform extends PlatformInterface {
  /// Constructs a OpenWithAppPlatform.
  OpenWithAppPlatform() : super(token: _token);

  static final Object _token = Object();

  static OpenWithAppPlatform _instance = MethodChannelOpenWithApp();

  /// The default instance of [OpenWithAppPlatform] to use.
  ///
  /// Defaults to [MethodChannelOpenWithApp].
  static OpenWithAppPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OpenWithAppPlatform] when
  /// they register themselves.
  static set instance(OpenWithAppPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the path of the file that opened the app, if any.
  Future<String?> getInitialFile() {
    throw UnimplementedError('getInitialFile() has not been implemented.');
  }

  /// Returns a stream of file paths opened while the app is running.
  Stream<String> getFileStream() {
    throw UnimplementedError('getFileStream() has not been implemented.');
  }
}
