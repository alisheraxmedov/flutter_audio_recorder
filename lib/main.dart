import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

// Desktop uchun window manager (conditional import)
import 'core/utils/window_manager_stub.dart'
    if (dart.library.io) 'core/utils/window_manager_helper.dart'
    as window_helper;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Load environment variables
  await dotenv.load(fileName: ".env").catchError((_) {
    debugPrint("Warning: .env file not found. Using default values.");
  });

  // Desktop window sozlamalari (faqat desktop uchun)
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    await window_helper.initDesktopWindow();
  }

  runApp(const MyApp());
}
