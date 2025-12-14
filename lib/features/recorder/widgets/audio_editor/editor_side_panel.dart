import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class EditorSidePanel extends StatelessWidget {
  final double width;
  final double refSize;
  final String title;
  final Widget child;

  const EditorSidePanel({
    super.key,
    required this.width,
    required this.refSize,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        border: Border(
          right: title == "Files"
              ? BorderSide(color: ColorClass.white.withValues(alpha: 0.1))
              : BorderSide.none,
          left: title == "Info"
              ? BorderSide(color: ColorClass.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(refSize * 0.03),
            color: Colors.black.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title == "Files") ...[
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: ColorClass.white,
                      size: refSize * 0.03,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: refSize * 0.02),
                ],
                TextWidget(
                  text: title,
                  fontSize: refSize * 0.03,
                  textColor: ColorClass.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(refSize * 0.03),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
