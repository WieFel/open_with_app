import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'open_with_app_platform_interface.dart';

/// An implementation of [OpenWithAppPlatform] that uses method channels.
class MethodChannelOpenWithApp extends OpenWithAppPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final initialFileChannel = const MethodChannel('open_with_app/initial_file');

  @visibleForTesting
  final fileStreamChannel = const EventChannel('open_with_app/file_stream');

  @override
  Future<String?> getInitialFile() async {
    final version = await initialFileChannel.invokeMethod<String>('getInitialFile');
    return version;
  }

  @override
  Stream<String> getFileStream() {
    return fileStreamChannel.receiveBroadcastStream().map((event) => event as String);
  }
}
