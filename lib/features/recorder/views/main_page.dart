import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/main_controller.dart';
import 'package:recorder/features/recorder/views/all_records_page.dart';
import 'package:recorder/features/recorder/views/recorder_page.dart';
import 'package:recorder/features/recorder/views/settings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide;

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
              _buildNavItem(
                context,
                icon: CupertinoIcons.list_bullet,
                index: 0,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(0),
              ),
              SizedBox(width: refSize * 0.1),
              _buildNavItem(
                context,
                icon: CupertinoIcons.mic_fill,
                index: 1,
                currentIndex: controller.currentIndex.value,
                onTap: () => controller.changePage(1),
              ),
              SizedBox(width: refSize * 0.1),
              _buildNavItem(
                context,
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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.glowBlue.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? ColorClass.glowBlue : ColorClass.textSecondary,
          size: MediaQuery.of(context).size.shortestSide * 0.07,
        ),
      ),
    );
  }
}
