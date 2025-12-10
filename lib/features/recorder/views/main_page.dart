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
import 'package:recorder/features/recorder/views/desktop_main_page.dart'; // Import Desktop Page
import 'package:recorder/features/recorder/views/recorder_page.dart';
import 'package:recorder/features/recorder/views/settings_page.dart';
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

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      return const DesktopMainPage();
    }

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [AllRecordsPage(), RecorderPage(), SettingsPage()],
        ),
      ),
      // Custom Bottom Navigation Pill
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: refSize * 0.8,
        margin: EdgeInsets.symmetric(
          horizontal: refSize * 0.05,
          vertical: size.height * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.02,
          horizontal: refSize * 0.1,
        ),
        decoration: BoxDecoration(
          color: ColorClass.buttonBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(refSize * 0.1),
          border: Border.all(color: Colors.white10),
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min, // Wrap content
            children: [
              CustomBottomNavItem(
                icon: CupertinoIcons.list_bullet,
                index: 0,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(0),
              ),
              SizedBox(width: refSize * 0.1),
              CustomBottomNavItem(
                icon: CupertinoIcons.mic_fill,
                index: 1,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(1),
              ),
              SizedBox(width: refSize * 0.1),
              CustomBottomNavItem(
                icon: CupertinoIcons.settings,
                index: 2,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
