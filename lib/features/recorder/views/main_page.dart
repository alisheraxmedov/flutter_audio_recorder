import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/main_controller.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/controllers/settings_controller.dart';
import 'package:recorder/features/recorder/views/all_records_page.dart';
import 'package:recorder/features/recorder/views/desktop_main_page.dart';
import 'package:recorder/features/recorder/views/recorder_page.dart';
import 'package:recorder/features/recorder/views/settings_page.dart';
import 'package:recorder/features/recorder/views/audio_editor_page.dart';
import 'package:recorder/features/recorder/widgets/custom_bottom_nav_item.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    Get.put(RecorderController());
    Get.put(AudioPlayerService());
    final controller = Get.put(MainController());
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);

    // Desktop uchun alohida sahifa
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      return const DesktopMainPage();
    }

    // Mobile uchun - Desktop bilan bir xil 4 ta sahifa
    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            AllRecordsPage(), // 0 - Dashboard/Records
            RecorderPage(), // 1 - Recorder
            AudioEditorPage(), // 2 - Audio Editor
            SettingsPage(), // 3 - Settings
          ],
        ),
      ),
      // Custom Bottom Navigation Pill - 4 ta item
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: refSize * 0.9,
        margin: EdgeInsets.symmetric(
          horizontal: refSize * 0.03,
          vertical: size.height * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: refSize * 0.06,
        ),
        decoration: BoxDecoration(
          color: ColorClass.buttonBg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(refSize * 0.08),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Dashboard (All Records)
              CustomBottomNavItem(
                icon: CupertinoIcons.list_bullet,
                index: 0,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(0),
              ),
              // Recorder
              CustomBottomNavItem(
                icon: CupertinoIcons.mic_fill,
                index: 1,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(1),
              ),
              // Audio Editor
              CustomBottomNavItem(
                icon: CupertinoIcons.waveform,
                index: 2,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(2),
              ),
              // Settings
              CustomBottomNavItem(
                icon: CupertinoIcons.settings,
                index: 3,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
