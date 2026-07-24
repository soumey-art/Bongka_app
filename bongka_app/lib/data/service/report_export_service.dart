import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../model/scan_model.dart';

// Handles saving a scan report to device storage or sharing it, using
// the report text already built by ScanModelX.reportText.
// Pulled out of AnalysisResultScreen so the screen doesn't need to know
// about file_picker / path_provider / share_plus.
class ReportExportService {
  String _fileName(ScanModel scan) =>
      'bongka_report_${scan.createdAt.millisecondsSinceEpoch}.txt';

  // Returns true if the file was actually saved (user didn't cancel).
  Future<bool> saveToDevice(ScanModel scan) async {
    final bytes = Uint8List.fromList(utf8.encode(scan.reportText));
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save phishing report',
      fileName: _fileName(scan),
      bytes: bytes,
    );
    if (path == null) return false; // user cancelled

    // file_picker has known cases where it returns a path but doesn't
    // actually write the bytes — verify before trusting it.
    final file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      await file.writeAsBytes(bytes); // write it ourselves as a fallback
    }
    return true;
  }

  Future<void> shareReport(ScanModel scan) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${_fileName(scan)}';
    final file = File(path);
    await file.writeAsString(scan.reportText);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Phishing analysis report (Risk: ${scan.riskLevel}).',
      subject: 'Bongka Phishing Report',
    );
  }
}
