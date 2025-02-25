import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/file_references.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<void> showImportProjectDialog({required BuildContext context}) => showDialog(
  context: context,
  builder: (context) {
    return ImportProjectDialog(onDone: () => Navigator.of(context).pop());
  },
);

class ImportProjectDialog extends StatelessWidget {
  final Function() onDone;

  const ImportProjectDialog({super.key, required this.onDone});

  Future<File?> _getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['.zip']);

    return result == null || result.files.single.path == null ? null : File(result.files.single.path!);
  }

  Future<Project> _readProjectFromArchiveFile(ArchiveFile archiveFile) async {
    final jsonString = utf8.decode(archiveFile.content as List<int>);
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return Project.fromJson(jsonData);
  }

  Future<Project?> _extractArchive(BuildContext context, File archiveFile) async {
    final directory = await getApplicationDocumentsDirectory();
    print('------ directory path: ${directory.path}');
    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    Project? project = null;

    for (final file in archive) {
      print('------------------------------');
      print('------ file name: ${file.name}');

      if (file.name.endsWith('.json')) {
        project = await _readProjectFromArchiveFile(file);
        print('------ project: ${project.toJson()}');
        continue;
      }

      print('------ is media file!');
      final filePath = '${directory.path}/media/${file.name}';
      print('------ media file path: $filePath');
      final mediaFile = File(filePath);
      print('------ new media file created!');
      await mediaFile.writeAsBytes(file.content as List<int>);
      print('------ media file written!');
    }

    return project;
  }

  Future<void> _importProject(BuildContext context) async {
    try {
      final file = await _getFile();

      if (file == null) {
        showSnackbar(context: context, message: 'No project file selected')();
        return;
      }

      final project = await _extractArchive(context, file);

      if (project == null) {
        showSnackbar(context: context, message: 'Error importing project')();
        return;
      }
      final projectLibrary = context.read<ProjectLibrary>();
      projectLibrary.addProject(project);
      await FileIO.saveProjectLibraryToJson(projectLibrary);
      await FileReferences.init(projectLibrary);

      showSnackbar(context: context, message: 'Project imported successfully!')();
    } catch (_) {
      showSnackbar(context: context, message: 'Error importing project')();
    } finally {
      onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Project", style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Would you like to import a project?", style: TextStyle(color: ColorTheme.primary)),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: onDone, child: Text('Cancel')),
            TIOFlatButton(onPressed: () => _importProject(context), text: "Import", boldText: true),
          ],
        ),
      ],
    );
  }
}
