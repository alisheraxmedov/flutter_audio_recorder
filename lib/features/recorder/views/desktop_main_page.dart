import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/main_controller.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/views/all_records_page.dart';
import 'package:recorder/features/recorder/views/settings_page.dart';
import 'package:recorder/features/recorder/widgets/recorder_body.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

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
    // final size = MediaQuery.of(context).size;

    // Fixed sizes for Static Desktop (950x650)
    // We don't rely heavily on screen size since the window is static.

    // Sidebar logic: Fixed width
    const double sidebarWidth = 260.0;

    // Inner scale for the RecorderBody components (Visualizer, Timer).
    // Passing 650 was too big. 380 is a reasonable "mobile-like" height for the inner content.
    const double contentRefSize = 380.0;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: Column(
        children: [
          // Main Body: Sidebar + Content
          Expanded(
            child: Row(
              children: [
                // SIDEBAR
                Container(
                  width: sidebarWidth,
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // APP NAME
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextWidget(
                          text: AppLocalizations.of(
                            context,
                          )!.appTitle.toUpperCase(),
                          textColor: ColorClass.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // MENU ITEMS
                      _buildMenuItem(
                        context,
                        mainController,
                        1,
                        AppLocalizations.of(context)!.appTitle,
                        Icons.mic,
                      ),
                      _buildMenuItem(
                        context,
                        mainController,
                        0,
                        AppLocalizations.of(context)!.allRecordsTitle,
                        Icons.list,
                      ),
                      _buildMenuItem(
                        context,
                        mainController,
                        2,
                        AppLocalizations.of(context)!.settingsTitle,
                        Icons.settings,
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT AREA
                Expanded(
                  child: Obx(() {
                    return IndexedStack(
                      index: mainController.currentIndex.value,
                      children: [
                        const AllRecordsPage(),
                        // Use RecorderBody directly to avoid duplicate controls
                        Center(
                          // Center the body vertically/horizontally
                          child: SizedBox(
                            // Constrain the height so the wave widget doesn't overflow
                            height: 500,
                            child: RecorderBody(
                              controller: Get.find<RecorderController>(),
                              refSize: contentRefSize,
                            ),
                          ),
                        ),
                        const SettingsPage(),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          // BOTTOM CONTROL BAR (Footer)
          Obx(() {
            if (mainController.currentIndex.value == 1) {
              return _buildBottomControlBar(context);
            } else {
              // Minimal footer
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MainController controller,
    int index,
    String title,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return InkWell(
        onTap: () => controller.changePage(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorClass.glowBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? ColorClass.glowBlue : Colors.transparent,
                width: 4.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ColorClass.glowBlue
                    : ColorClass.textSecondary,
                size: 24.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextWidget(
                  text: title,
                  textColor: isSelected
                      ? ColorClass.white
                      : ColorClass.textSecondary,
                  fontSize: 16.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomControlBar(BuildContext context) {
    final recorderController = Get.find<RecorderController>();
    return Container(
      height: 100, // Fixed reasonable height
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
            size: 50.0,
          ),
          const SizedBox(width: 32),
          // Play/Pause/Record
          Obx(() {
            final isRecording = recorderController.isRecording.value;
            return _buildCircleButton(
              icon: isRecording ? Icons.pause : Icons.play_arrow,
              onTap: () => recorderController.toggleRecording(),
              isPrimary: true,
              size: 70.0,
            );
          }),
          const SizedBox(width: 32),
          // Close / Setup
          _buildCircleButton(
            icon: Icons.close,
            onTap: () {},
            isPrimary: false,
            size: 50.0,
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
