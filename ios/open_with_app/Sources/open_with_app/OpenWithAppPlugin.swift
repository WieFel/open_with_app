import Flutter
import UIKit

public class OpenWithAppPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
    private var initialFile: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "open_with_app/initial_file", binaryMessenger: registrar.messenger())
      let instance = OpenWithAppPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)

      let eventChannel = FlutterEventChannel(name: "open_with_app/file_stream", binaryMessenger: registrar.messenger())
      eventChannel.setStreamHandler(instance)

      registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "getInitialFile" {
        result(initialFile)
        initialFile = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      if url.isFileURL {
          handleFile(url: url)
          return true
      }
      return false
    }

    private func handleFile(url: URL) {
        var filePath = url.path
        var isSecurityScoped = false

        if url.startAccessingSecurityScopedResource() {
            isSecurityScoped = true
        }

        // Copy to temp directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let tempUrl = tempDir.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: tempUrl.path) {
                try FileManager.default.removeItem(at: tempUrl)
            }
            try FileManager.default.copyItem(at: url, to: tempUrl)
            filePath = tempUrl.path
        } catch {
            print("Error copying file to temp directory: \(error)")
        }

        if isSecurityScoped {
            url.stopAccessingSecurityScopedResource()
        }

        if let sink = eventSink {
            sink(filePath)
        } else {
            initialFile = filePath
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
