import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class AllRecordsPage extends StatelessWidget {
  const AllRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecorderController>();
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        title: TextWidget(
          text: AppLocalizations.of(context)!.allRecordsTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ColorClass.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return Center(
            child: TextWidget(
              text: "No records found",
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.035,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(refSize * 0.05),
          itemCount: controller.records.length,
          itemBuilder: (context, index) {
            // Get filename from path
            final path = controller.records[index];
            final name = path.split('/').last;

            return Container(
              margin: EdgeInsets.only(bottom: refSize * 0.03),
              padding: EdgeInsets.symmetric(
                horizontal: refSize * 0.05,
                vertical: refSize * 0.03,
              ),
              decoration: BoxDecoration(
                color: ColorClass.buttonBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(refSize * 0.03),
                    decoration: BoxDecoration(
                      color: ColorClass.glowBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.audiotrack,
                      color: ColorClass.glowBlue,
                      size: refSize * 0.06,
                    ),
                  ),
                  SizedBox(width: refSize * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: name,
                          textColor: ColorClass.white,
                          fontSize: refSize * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                        // Can add date/duration if metadata available
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill,
                    color: ColorClass.white,
                    size: refSize * 0.08,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
