import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/all_records/create_folder_dialog.dart';
import 'package:recorder/features/recorder/widgets/all_records/delete_dialog.dart';
import 'package:recorder/features/recorder/widgets/all_records/folder_options_sheet.dart';
import 'package:recorder/features/recorder/widgets/all_records/folder_tile.dart';
import 'package:recorder/features/recorder/widgets/all_records/move_dialog.dart';
import 'package:recorder/features/recorder/widgets/all_records/record_expansion_tile.dart';
import 'package:recorder/features/recorder/widgets/all_records/rename_dialog.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/features/recorder/models/sort_option.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class AllRecordsPage extends StatelessWidget {
  const AllRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecorderController>();
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.canGoBack) {
          controller.goBack();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: ColorClass.darkBackground,
        appBar: AppBar(
          title: Obx(() {
            final path = controller.currentPath.value;
            final folderName = path.split(Platform.pathSeparator).last;
            // Show "All Records" if root, otherwise folder name
            final title = !controller.canGoBack
                ? l10n.allRecordsTitle
                : folderName;
            return TextWidget(
              text: title,
              textColor: ColorClass.white,
              fontSize: refSize * 0.045,
            );
          }),
          backgroundColor: ColorClass.transparent,
          iconTheme: const IconThemeData(color: ColorClass.white),
          centerTitle: true,
          leading: Obx(() {
            // Explicitly listen to currentPath changes
            final _ = controller.currentPath.value;
            if (controller.canGoBack) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.goBack,
              );
            }
            return const BackButton();
          }),
          actions: [
            Obx(
              () => PopupMenuButton<SortOption>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: 4),
                    TextWidget(
                      text: _getSortLabel(
                        controller.currentSortOption.value,
                        l10n,
                      ),
                      fontSize: refSize * 0.028,
                      textColor: ColorClass.white,
                    ),
                  ],
                ),
                tooltip: l10n.sortTitle,
                color: ColorClass.darkBackground,
                onSelected: (option) => controller.changeSortOption(option),
                itemBuilder: (context) => SortOption.values.map((option) {
                  final isSelected =
                      controller.currentSortOption.value == option;
                  return PopupMenuItem<SortOption>(
                    value: option,
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: ColorClass.glowBlue,
                            size: refSize * 0.04,
                          )
                        else
                          SizedBox(width: refSize * 0.04),
                        SizedBox(width: refSize * 0.02),
                        TextWidget(
                          text: _getSortLabel(option, l10n),
                          textColor: isSelected
                              ? ColorClass.glowBlue
                              : ColorClass.white,
                          fontSize: refSize * 0.032,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: l10n.newFolder,
              onPressed: () => CreateFolderDialog.show(
                context,
                controller: controller,
                refSize: refSize,
                l10n: l10n,
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.entities.isEmpty) {
            return Center(
              child: TextWidget(
                text: l10n.noRecordsFound,
                textColor: ColorClass.textSecondary,
                fontSize: refSize * 0.035,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(refSize * 0.05),
            itemCount: controller.entities.length,
            itemBuilder: (context, index) {
              final entity = controller.entities[index];
              final name = entity.path.split(Platform.pathSeparator).last;

              if (entity is Directory) {
                return FolderTile(
                  controller: controller,
                  path: entity.path,
                  name: name,
                  refSize: refSize,
                  l10n: l10n,
                  onLongPress: () {
                    FolderOptionsSheet.show(
                      context,
                      controller: controller,
                      path: entity.path,
                      name: name,
                      refSize: refSize,
                      l10n: l10n,
                    );
                  },
                );
              } else {
                return RecordExpansionTile(
                  context: context,
                  controller: controller,
                  path: entity.path,
                  name: name,
                  refSize: refSize,
                  l10n: l10n,
                  onRename: () => RenameDialog.show(
                    context,
                    controller: controller,
                    path: entity.path,
                    currentName: name,
                    refSize: refSize,
                    l10n: l10n,
                  ),
                  onMove: () => MoveDialog.show(
                    context,
                    controller: controller,
                    srcPath: entity.path,
                    refSize: refSize,
                    l10n: l10n,
                  ),
                  onDelete: () => DeleteDialog.show(
                    context,
                    controller: controller,
                    path: entity.path,
                    name: name,
                    refSize: refSize,
                    l10n: l10n,
                  ),
                  onShare: _shareFile,
                );
              }
            },
          );
        }),
      ),
    );
  }

  void _shareFile(String path) async {
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
    } catch (e) {
      // Silent fail
    }
  }

  String _getSortLabel(SortOption option, AppLocalizations l10n) {
    switch (option) {
      case SortOption.dateNew:
        return l10n.sortDateNew;
      case SortOption.dateOld:
        return l10n.sortDateOld;
      case SortOption.nameAsc:
        return l10n.sortNameAsc;
      case SortOption.nameDesc:
        return l10n.sortNameDesc;
      case SortOption.sizeBig:
        return l10n.sortSizeBig;
      case SortOption.sizeSmall:
        return l10n.sortSizeSmall;
      case SortOption.durLong:
        return l10n.sortDurLong;
      case SortOption.durShort:
        return l10n.sortDurShort;
    }
  }
}
