import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

/// A reusable, customizable dialog widget using AwesomeDialog package.
/// Can be used throughout the application for various dialog purposes.
class AppDialog {
  /// Shows a customizable dialog with AwesomeDialog.
  ///
  /// [context] - BuildContext (required)
  /// [title] - Dialog title text
  /// [description] - Dialog description text
  /// [dialogType] - Type of dialog (info, warning, error, success, noHeader)
  /// [animType] - Animation type for dialog entrance
  /// [body] - Custom body widget (overrides title and description)
  /// [btnOkText] - OK button text
  /// [btnCancelText] - Cancel button text
  /// [btnOkOnPress] - OK button callback
  /// [btnCancelOnPress] - Cancel button callback
  /// [width] - Dialog width
  /// [showCloseIcon] - Whether to show close icon
  /// [dismissOnTouchOutside] - Whether to dismiss on outside touch
  static void show({
    required BuildContext context,
    String? title,
    String? description,
    DialogType dialogType = DialogType.info,
    AnimType animType = AnimType.scale,
    Widget? body,
    String? btnOkText,
    String? btnCancelText,
    VoidCallback? btnOkOnPress,
    VoidCallback? btnCancelOnPress,
    double? width,
    bool showCloseIcon = false,
    bool dismissOnTouchOutside = true,
    bool dismissOnBackKeyPress = true,
    Color? dialogBackgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? buttonsBorderRadius,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: animType,
      title: title,
      desc: description,
      body: body,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      btnOkOnPress: btnOkOnPress,
      btnCancelOnPress: btnCancelOnPress,
      width: width,
      showCloseIcon: showCloseIcon,
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnBackKeyPress,
      dialogBackgroundColor: dialogBackgroundColor ?? ColorClass.darkNavy,
      borderSide: borderColor != null
          ? BorderSide(color: borderColor, width: borderWidth)
          : null,
      padding: padding ?? const EdgeInsets.all(16),
      buttonsBorderRadius: buttonsBorderRadius ?? BorderRadius.circular(8),
      closeIcon: showCloseIcon
          ? const Icon(Icons.close, color: ColorClass.white54, size: 20)
          : null,
      btnOkColor: ColorClass.neonTeal,
      btnCancelColor: ColorClass.neonPurple,
      buttonsTextStyle: const TextStyle(
        color: ColorClass.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleTextStyle: const TextStyle(
        color: ColorClass.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      descTextStyle: const TextStyle(color: ColorClass.white70, fontSize: 14),
    ).show();
  }

  /// Shows an info dialog
  static void info({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    VoidCallback? onOk,
    double? width,
  }) {
    show(
      context: context,
      title: title,
      description: description,
      body: body,
      dialogType: DialogType.info,
      btnOkOnPress: onOk ?? () {},
      width: width,
    );
  }

  /// Shows a success dialog
  static void success({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    VoidCallback? onOk,
    double? width,
  }) {
    show(
      context: context,
      title: title,
      description: description,
      body: body,
      dialogType: DialogType.success,
      btnOkOnPress: onOk ?? () {},
      width: width,
    );
  }

  /// Shows a warning dialog
  static void warning({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    VoidCallback? onOk,
    VoidCallback? onCancel,
    double? width,
  }) {
    show(
      context: context,
      title: title,
      description: description,
      body: body,
      dialogType: DialogType.warning,
      btnOkOnPress: onOk ?? () {},
      btnCancelOnPress: onCancel,
      width: width,
    );
  }

  /// Shows an error dialog
  static void error({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    VoidCallback? onOk,
    double? width,
  }) {
    show(
      context: context,
      title: title,
      description: description,
      body: body,
      dialogType: DialogType.error,
      btnOkOnPress: onOk ?? () {},
      width: width,
    );
  }

  /// Shows a confirmation dialog with OK and Cancel buttons
  static void confirm({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    String okText = 'OK',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    double? width,
  }) {
    show(
      context: context,
      title: title,
      description: description,
      body: body,
      dialogType: DialogType.question,
      btnOkText: okText,
      btnCancelText: cancelText,
      btnOkOnPress: onConfirm,
      btnCancelOnPress: onCancel ?? () {},
      width: width,
    );
  }

  /// Shows a custom dialog with no header (fully customizable body)
  static void custom({
    required BuildContext context,
    required Widget body,
    VoidCallback? onOk,
    VoidCallback? onCancel,
    String? btnOkText,
    String? btnCancelText,
    double? width,
    bool showCloseIcon = true,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
  }) {
    show(
      context: context,
      body: body,
      dialogType: DialogType.noHeader,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      btnOkOnPress: onOk,
      btnCancelOnPress: onCancel,
      width: width,
      showCloseIcon: showCloseIcon,
      dialogBackgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
    );
  }
}

/// A styled option tile that can be used inside dialogs
class DialogOptionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const DialogOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<DialogOptionTile> createState() => _DialogOptionTileState();
}

class _DialogOptionTileState extends State<DialogOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.15)
                : ColorClass.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : ColorClass.white10,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: widget.title,
                      textColor: ColorClass.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      TextWidget(
                        text: widget.subtitle!,
                        textColor: ColorClass.white54,
                        fontSize: 12,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _isHovered ? widget.color : ColorClass.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
