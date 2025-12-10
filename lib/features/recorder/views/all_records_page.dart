import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
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
          backgroundColor: Colors.transparent,
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
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: "New Folder",
              onPressed: () =>
                  _showCreateFolderDialog(context, controller, refSize),
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
                return _buildFolderTile(
                  context: context,
                  controller: controller,
                  path: entity.path,
                  name: name,
                  refSize: refSize,
                  l10n: l10n,
                );
              } else {
                return _buildRecordExpansionTile(
                  context: context,
                  controller: controller,
                  path: entity.path,
                  name: name,
                  refSize: refSize,
                  l10n: l10n,
                );
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildFolderTile({
    required BuildContext context,
    required RecorderController controller,
    required String path,
    required String name,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.04),
      decoration: BoxDecoration(
        color: ColorClass.buttonBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: refSize * 0.04,
          vertical: refSize * 0.015,
        ),
        leading: Icon(
          Icons.folder_open_rounded,
          color: ColorClass.folderIcon,
          size: refSize * 0.07,
        ),
        title: TextWidget(
          text: name,
          textColor: ColorClass.white,
          fontSize: refSize * 0.035,
          fontWeight: FontWeight.w500,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: ColorClass.textSecondary,
          size: refSize * 0.035,
        ),
        onTap: () => controller.openFolder(path),
        onLongPress: () {
          // Future: Add menu to rename/delete folder
          _showFolderOptions(context, controller, path, name, refSize, l10n);
        },
      ),
    );
  }

  Widget _buildRecordExpansionTile({
    required BuildContext context,
    required RecorderController controller,
    required String path,
    required String name,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.04),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: refSize * 0.035,
            vertical: refSize * 0.02,
          ),
          leading: Icon(
            Icons.audiotrack,
            color: ColorClass.glowBlue,
            size: refSize * 0.06,
          ),
          title: TextWidget(
            text: name,
            textColor: ColorClass.white,
            fontSize: refSize * 0.035,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: ColorClass.textSecondary,
            size: refSize * 0.06,
          ),
          iconColor: ColorClass.glowBlue,
          collapsedIconColor: ColorClass.textSecondary,
          childrenPadding: EdgeInsets.symmetric(
            horizontal: refSize * 0.04,
            vertical: refSize * 0.03,
          ),
          children: [
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                _buildActionButton(
                  icon: Icons.pause,
                  color: ColorClass.glowBlue,
                  refSize: refSize,
                  onTap: () {
                    // TODO: Implement play/pause
                  },
                ),
                // Edit/Rename button
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: ColorClass.editIcon,
                  refSize: refSize,
                  onTap: () => _showRenameDialog(
                    context,
                    controller,
                    path,
                    name,
                    refSize,
                    l10n,
                  ),
                ),
                // Move button
                _buildActionButton(
                  icon: Icons.drive_file_move_outline,
                  color: ColorClass.moveIcon,
                  refSize: refSize,
                  onTap: () =>
                      _showMoveDialog(context, controller, path, refSize),
                ),
                // Delete button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: ColorClass.deleteIcon,
                  refSize: refSize,
                  onTap: () => _confirmDelete(
                    context,
                    controller,
                    path,
                    name,
                    refSize,
                    l10n,
                  ),
                ),
                // Share button
                _buildActionButton(
                  icon: Icons.ios_share,
                  color: ColorClass.glowBlue,
                  refSize: refSize,
                  onTap: () => _shareFile(path),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double refSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(refSize * 0.03),
      child: Container(
        padding: EdgeInsets.all(refSize * 0.03),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(refSize * 0.03),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: refSize * 0.04),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RecorderController controller,
    String path,
    String name,
    double refSize,
    AppLocalizations l10n,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.deleteRecordingTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextWidget(
          text: l10n.deleteRecordingMessage(name),
          textColor: ColorClass.textSecondary,
          fontSize: refSize * 0.03,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final entity = FileSystemEntity.isDirectorySync(path)
                    ? Directory(path)
                    : File(path);
                if (await entity.exists()) {
                  await entity.delete(recursive: true);
                  await controller.refreshList();
                }
              } catch (e) {
                // Silent fail
              }
            },
            child: Text(
              l10n.delete,
              style: TextStyle(
                color: ColorClass.deleteIcon,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
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

  void _showRenameDialog(
    BuildContext context,
    RecorderController controller,
    String path,
    String currentName,
    double refSize,
    AppLocalizations l10n,
  ) {
    final isDirectory = FileSystemEntity.isDirectorySync(path);
    final extension = !isDirectory && currentName.contains('.')
        ? '.${currentName.split('.').last}'
        : '';
    final nameWithoutExtension = !isDirectory && currentName.contains('.')
        ? currentName.substring(0, currentName.lastIndexOf('.'))
        : currentName;

    final textController = TextEditingController(text: nameWithoutExtension);

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.renameRecording,
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: ColorClass.white, fontSize: refSize * 0.035),
          decoration: InputDecoration(
            hintText: l10n.enterNewName,
            hintStyle: TextStyle(
              color: ColorClass.textSecondary.withValues(alpha: 0.5),
              fontSize: refSize * 0.03,
            ),
            suffixText: extension,
            suffixStyle: TextStyle(
              color: ColorClass.textSecondary,
              fontSize: refSize * 0.03,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.textSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.glowBlue),
            ),
            filled: true,
            fillColor: ColorClass.buttonBg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isEmpty) return;

              Get.back();

              try {
                // For files, append extension. For folders, just newName.
                final fullName = '$newName$extension';

                final parent = Directory(path).parent.path;
                final newPath = '$parent/$fullName';

                final entity = isDirectory ? Directory(newPath) : File(newPath);

                if (await entity.exists()) return;

                if (isDirectory) {
                  await Directory(path).rename(newPath);
                } else {
                  await File(path).rename(newPath);
                }

                await controller.refreshList();
              } catch (e) {
                // Silent fail
              }
            },
            child: Text(
              l10n.rename,
              style: TextStyle(
                color: ColorClass.glowBlue,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(
    BuildContext context,
    RecorderController controller,
    double refSize,
  ) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: "New Folder",
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: ColorClass.white, fontSize: refSize * 0.035),
          decoration: InputDecoration(
            hintText: "Folder Name",
            hintStyle: TextStyle(
              color: ColorClass.textSecondary.withValues(alpha: 0.5),
              fontSize: refSize * 0.03,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.textSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.glowBlue),
            ),
            filled: true,
            fillColor: ColorClass.buttonBg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                controller.createFolder(name);
              }
              Get.back();
            },
            child: Text(
              "Create",
              style: TextStyle(
                color: ColorClass.glowBlue,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFolderOptions(
    BuildContext context,
    RecorderController controller,
    String path,
    String name,
    double refSize,
    AppLocalizations l10n,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(refSize * 0.05),
        decoration: BoxDecoration(
          color: ColorClass.darkBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(refSize * 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: name,
              textColor: ColorClass.white,
              fontSize: refSize * 0.04,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: refSize * 0.04),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: ColorClass.editIcon,
              ),
              title: TextWidget(
                text: l10n.rename,
                textColor: Colors.white,
                fontSize: refSize * 0.035,
              ),
              onTap: () {
                Get.back();
                _showRenameDialog(
                  context,
                  controller,
                  path,
                  name,
                  refSize,
                  l10n,
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: ColorClass.deleteIcon,
              ),
              title: TextWidget(
                text: l10n.delete,
                textColor: Colors.white,
                fontSize: refSize * 0.035,
              ),
              onTap: () {
                Get.back();
                _confirmDelete(context, controller, path, name, refSize, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDialog(
    BuildContext context,
    RecorderController controller,
    String srcPath,
    double refSize,
  ) {
    // Get list of folders in current directory to allow moving INTO them
    final folders = controller.entities.whereType<Directory>().toList();
    // Exclude the source itself if it's a directory we are trying to move
    folders.removeWhere((dir) => dir.path == srcPath);

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: "Move to...",
          textColor: Colors.white,
          fontSize: refSize * 0.045,
          fontWeight: FontWeight.bold,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (controller.canGoBack)
                ListTile(
                  leading: const Icon(
                    Icons.arrow_upward,
                    color: ColorClass.glowBlue,
                  ),
                  title: TextWidget(
                    text: "Extract from folder",
                    textColor: Colors.white,
                    fontSize: refSize * 0.035,
                  ),
                  onTap: () {
                    final parent = Directory(
                      controller.currentPath.value,
                    ).parent.path;
                    controller.moveEntity(srcPath, parent);
                    Get.back();
                  },
                ),
              if (folders.isEmpty && !controller.canGoBack)
                Padding(
                  padding: EdgeInsets.all(refSize * 0.02),
                  child: TextWidget(
                    text: "No folders",
                    textColor: ColorClass.textSecondary,
                    fontSize: refSize * 0.03,
                    textAlign: TextAlign.center,
                  ),
                ),
              ...folders.map((dir) {
                final folderName = dir.path.split(Platform.pathSeparator).last;
                return ListTile(
                  leading: const Icon(
                    Icons.folder,
                    color: ColorClass.folderIcon,
                  ),
                  title: TextWidget(
                    text: folderName,
                    textColor: Colors.white,
                    fontSize: refSize * 0.035,
                  ),
                  onTap: () {
                    controller.moveEntity(srcPath, dir.path);
                    Get.back();
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
