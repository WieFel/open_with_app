import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_with_app/open_with_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _openWithAppPlugin = OpenWithApp();
  String _filePath = 'No file opened';
  String _fileContent = 'No file content';
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? initialFile;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialFile = await _openWithAppPlugin.getInitialFile();
    } on PlatformException {
      debugPrint('Failed to get initial file.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (initialFile != null) {
      _handleFile(initialFile);
    }

    _streamSubscription = _openWithAppPlugin.getFileStream().listen((filePath) {
      if (!mounted) return;
      _handleFile(filePath);
    });
  }

  Future<void> _handleFile(String filePath) async {
    String content;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        content = 'File does not exist';
      }
    } catch (e) {
      content = 'Error reading file: $e';
    }

    setState(() {
      _filePath = filePath;
      _fileContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('OpenWithApp Example')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'File:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(_filePath),
                  const SizedBox(height: 20),
                  const Text(
                    'Content:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(_fileContent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
