import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

Future<void> showExportProjectDialog({required BuildContext context, required String title}) => showDialog(
      context: context,
      builder: (context) {
        return ExportProjectDialog(
          title: title,
          onCloseDialog: () => Navigator.of(context).pop(),
        );
      },
    );

class ExportProjectDialog extends StatelessWidget {
  final String title;
  final Function() onCloseDialog;

  const ExportProjectDialog({
    super.key,
    required this.title,
    required this.onCloseDialog,
  });

  Future<String> _writeJsonFile(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tio-music-${_sanitizeString(title)}.json';
    final file = File(filePath);
    final projectLibrary = context.read<ProjectLibrary>();

    Map<String, dynamic> jsonData = projectLibrary.projects.first.toJson();
    String jsonString = jsonEncode(jsonData);

    await file.writeAsString(jsonString);
    return filePath;
  }

  Future<void> _exportFile(BuildContext context) async {
    try {
      final filePath = await _writeJsonFile(context);

      await Share.shareXFiles([XFile(filePath)]);

      showSnackbar(context: context, message: 'Project file exported successfully!')();

      onCloseDialog();
    } catch (e) {
      print('Error exporting project file: $e');
      showSnackbar(context: context, message: 'Error exporting project file')();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Export Project", style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Do you really want to export the project?", style: TextStyle(color: ColorTheme.primary)),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: onCloseDialog,
              child: Text('Cancel'),
            ),
            TIOFlatButton(
              onPressed: () => _exportFile(context),
              text: "Export",
              boldText: true,
            ),
          ],
        ),
      ],
    );
  }
}
