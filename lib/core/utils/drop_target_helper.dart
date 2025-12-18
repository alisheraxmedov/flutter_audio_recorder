import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

/// Desktop platformalari uchun haqiqiy DropTarget
Widget buildDropTarget({
  required void Function(String path) onFileDrop,
  required Widget child,
}) {
  // Faqat desktop uchun
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return DropTarget(
      onDragDone: (detail) {
        if (detail.files.isNotEmpty) {
          onFileDrop(detail.files.first.path);
        }
      },
      child: child,
    );
  }

  // Aks holda oddiy child
  return child;
}
