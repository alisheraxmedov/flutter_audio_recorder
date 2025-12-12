import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/features/recorder/views/main_page.dart';
import 'package:recorder/core/services/share_service.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      initialBinding: BindingsBuilder(() {
        Get.put(ShareService());
      }),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('uz'), // Uzbek
        Locale('ru'), // Russian
      ],
    );
  }
}
