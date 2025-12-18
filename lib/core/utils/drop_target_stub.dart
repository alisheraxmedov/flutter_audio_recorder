import 'package:flutter/material.dart';

/// Mobile/Web platformalari uchun stub
/// DropTarget hech narsa qilmaydi - faqat child qaytaradi
Widget buildDropTarget({
  required void Function(String path) onFileDrop,
  required Widget child,
}) {
  // Mobile uchun hech qanday drop funksiya yo'q
  return child;
}
