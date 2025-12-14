import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Load environment variables
  await dotenv.load(fileName: ".env").catchError((_) {
    debugPrint("Warning: .env file not found. Using default values.");
  });

  if (!kIsWeb &&
      (kDebugMode ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS)) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(950, 650),
        minimumSize: Size(950, 650),
        maximumSize: Size(950, 650),
        center: true,
        title: "Voice Recorder",
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(const MyApp());
}
