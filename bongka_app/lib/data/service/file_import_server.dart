import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Lets the user pick a .txt or .eml file from their phone and returns
// its text content. Used by the Phishing Detector screen's "Import file"
// button so the screen doesn't need to touch file_picker / dart:io itself.
class FileImportService {
  Future<ImportedFile?> pickTextFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'eml'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    String? content;

    if (picked.bytes != null) {
      content = String.fromCharCodes(picked.bytes!);
    } else if (picked.path != null) {
      content = await File(picked.path!).readAsString();
    }

    if (content == null) return null;

    return ImportedFile(name: picked.name, content: content);
  }
}

class ImportedFile {
  final String name;
  final String content;

  ImportedFile({required this.name, required this.content});
}
