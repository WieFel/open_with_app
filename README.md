# open_with_app

A plugin for opening specific file types with your app

## Usage

```dart
final _openWithAppPlugin = OpenWithApp();

// Check if app was opened with a file
String? initialFile = await _openWithAppPlugin.getInitialFile();

// Listen for new files opened while app is running
_openWithAppPlugin.getFileStream().listen((filePath) {
  print("New file: $filePath");
});
```

## Setup

### Android

Update your `android/app/src/main/AndroidManifest.xml` to include an intent filter for your custom file extension (e.g., `.owa`).

```xml
<activity ...>
    ...
    <!-- Add this intent filter -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="file" />
        <data android:scheme="content" />
        <data android:mimeType="*/*" />
        <data android:host="*" />
        <data android:pathPattern=".*\\.owa" /> <!-- Change .owa to your extension -->
    </intent-filter>

     <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="*/*" />
    </intent-filter>
</activity>
```

### iOS

Update your `ios/Runner/Info.plist` to register the document type.

```xml
<dict>
    ...
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    <key>UIFileSharingEnabled</key>
    <true/>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>OWA File</string> <!-- Change to your file type name -->
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>dev.wiefel.owa</string> <!-- Change to your identifier -->
            </array>
        </dict>
    </array>
    <key>UTExportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.data</string>
            </array>
            <key>UTTypeDescription</key>
            <string>OWA File</string> <!-- Change to your file description -->
            <key>UTTypeIdentifier</key>
            <string>dev.wiefel.owa</string> <!-- Change to your identifier -->
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <array>
                    <string>owa</string> <!-- Change to your extension -->
                </array>
            </dict>
        </dict>
    </array>
</dict>
```

