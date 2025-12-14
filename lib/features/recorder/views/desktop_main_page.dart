import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/main_controller.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/views/all_records_page.dart';
import 'package:recorder/features/recorder/views/settings_page.dart';
import 'package:recorder/features/recorder/views/audio_editor_page.dart';
import 'package:recorder/features/recorder/widgets/recorder_body.dart';

class DesktopMainPage extends StatelessWidget {
  const DesktopMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controllers if not present
    if (!Get.isRegistered<RecorderController>()) {
      Get.put(RecorderController());
    }
    if (!Get.isRegistered<AudioPlayerService>()) {
      Get.put(AudioPlayerService());
    }
    final mainController = Get.find<MainController>();

    // MediaQuery based responsive sizing
    final size = MediaQuery.of(context).size;
    final refSize = size.shortestSide.clamp(400.0, 800.0);

    // Sidebar width based on screen width (6% of width, clamped between 60-80)
    final sidebarWidth = (size.width * 0.06).clamp(60.0, 80.0);

    // Content ref size for recorder body
    final contentRefSize = refSize * 0.55;

    // Bottom bar height
    final bottomBarHeight = refSize * 0.12;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: Row(
        children: [
          // NEW VERTICAL ICON SIDEBAR
          _buildIconSidebar(context, mainController, sidebarWidth, refSize),

          // MAIN CONTENT AREA
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: mainController.currentIndex.value,
                children: [
                  const AllRecordsPage(),
                  // Recorder page
                  Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: size.height * 0.65,
                          child: RecorderBody(
                            controller: Get.find<RecorderController>(),
                            refSize: contentRefSize,
                          ),
                        ),
                      ),
                      // Bottom control bar for recorder
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildBottomControlBar(
                          context,
                          bottomBarHeight,
                          refSize,
                        ),
                      ),
                    ],
                  ),
                  const AudioEditorPage(),
                  const SettingsPage(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// New vertical icon-only sidebar matching the design
  Widget _buildIconSidebar(
    BuildContext context,
    MainController controller,
    double sidebarWidth,
    double refSize,
  ) {
    final logoSize = refSize * 0.06;
    final iconSize = refSize * 0.03;
    final itemHeight = refSize * 0.07;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            ColorClass.glowPurple.withValues(alpha: 0.3),
            const Color(0xFF0F0F1A),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: ColorClass.glowPurple.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: refSize * 0.03),

          // LOGO / BRANDING
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [ColorClass.glowBlue, ColorClass.glowPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorClass.glowBlue.withValues(alpha: 0.5),
                  blurRadius: refSize * 0.02,
                  spreadRadius: refSize * 0.003,
                ),
              ],
            ),
            child: Icon(Icons.bolt, color: Colors.white, size: logoSize * 0.55),
          ),

          SizedBox(height: refSize * 0.04),

          // MENU ITEMS
          _buildSidebarIcon(
            controller,
            0,
            Icons.dashboard_outlined,
            Icons.dashboard,
            sidebarWidth,
            itemHeight,
            iconSize,
          ),
          _buildSidebarIcon(
            controller,
            1,
            Icons.mic_none_outlined,
            Icons.mic,
            sidebarWidth,
            itemHeight,
            iconSize,
          ),
          _buildSidebarIcon(
            controller,
            2,
            Icons.edit_outlined,
            Icons.edit,
            sidebarWidth,
            itemHeight,
            iconSize,
          ),
          _buildSidebarIcon(
            controller,
            3,
            Icons.settings_outlined,
            Icons.settings,
            sidebarWidth,
            itemHeight,
            iconSize,
          ),

          const Spacer(),

          // BOTTOM ICON (Logout/Exit)
          Container(
            margin: EdgeInsets.only(bottom: refSize * 0.03),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.logout,
                color: ColorClass.textSecondary,
                size: iconSize,
              ),
              tooltip: 'Exit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(
    MainController controller,
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    double sidebarWidth,
    double itemHeight,
    double iconSize,
  ) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changePage(index),
        child: Container(
          width: sidebarWidth,
          height: itemHeight,
          margin: EdgeInsets.symmetric(vertical: itemHeight * 0.08),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorClass.glowPurple.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? ColorClass.glowPurple : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected
                ? ColorClass.glowPurple
                : ColorClass.textSecondary,
            size: iconSize,
          ),
        ),
      );
    });
  }

  Widget _buildBottomControlBar(
    BuildContext context,
    double barHeight,
    double refSize,
  ) {
    final recorderController = Get.find<RecorderController>();
    final primaryButtonSize = refSize * 0.09;
    final secondaryButtonSize = refSize * 0.065;
    final buttonSpacing = refSize * 0.04;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stop
          _buildCircleButton(
            icon: Icons.stop,
            onTap: () => recorderController.stopRecording(),
            isPrimary: false,
            size: secondaryButtonSize,
          ),
          SizedBox(width: buttonSpacing),
          // Play/Pause/Record
          Obx(() {
            final isRecording = recorderController.isRecording.value;
            return _buildCircleButton(
              icon: isRecording ? Icons.pause : Icons.play_arrow,
              onTap: () => recorderController.toggleRecording(),
              isPrimary: true,
              size: primaryButtonSize,
            );
          }),
          SizedBox(width: buttonSpacing),
          // Close / Setup
          _buildCircleButton(
            icon: Icons.close,
            onTap: () {},
            isPrimary: false,
            size: secondaryButtonSize,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    required double size,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? ColorClass.white : Colors.transparent,
          border: isPrimary ? null : Border.all(color: ColorClass.white),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black : ColorClass.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
