import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        title: TextWidget(
          text: AppLocalizations.of(context)!.settingsTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ColorClass.white),
      ),
      body: Center(
        child: TextWidget(
          text: "Settings will be here",
          textColor: ColorClass.textSecondary,
          fontSize: refSize * 0.035,
        ),
      ),
    );
  }
}
