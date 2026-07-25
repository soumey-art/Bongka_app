import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../model/scan_model.dart';

class ReportExportService {
  String _fileName(ScanModel scan) =>
      'bongka_report_${scan.createdAt.millisecondsSinceEpoch}.pdf';

  Future<Uint8List> _buildPdfBytes(ScanModel scan) async {
    final doc = pw.Document();
    final riskColor = PdfColor.fromInt(scan.riskColor.toARGB32());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Text(
            'BONGKA PHISHING REPORT',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: ${scan.createdAt}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),

          // Risk banner
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: riskColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              '${scan.riskLevel} RISK  —  Score: ${scan.riskScore}/100',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Scanned content
          _sectionTitle('Scanned Content'),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              scan.messageText,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 20),

          // Threats
          _sectionTitle('Threats Detected (${scan.threats.length})'),
          if (scan.threats.isEmpty)
            pw.Text(
              'No threats detected.',
              style: const pw.TextStyle(fontSize: 11),
            ),
          for (final t in scan.threats)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Bullet(
                text: '[${t.severity}] ${t.explanation}',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          pw.SizedBox(height: 20),

          // Suspicious links
          _sectionTitle('Suspicious URLs'),
          if (scan.suspiciousLinks.isEmpty)
            pw.Text('None found.', style: const pw.TextStyle(fontSize: 11)),
          for (final link in scan.suspiciousLinks)
            pw.Text(
              link,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.blue),
            ),
          pw.SizedBox(height: 20),

          // Safe Browsing note
          _sectionTitle('Google Safe Browsing'),
          pw.Text(
            scan.safeBrowsingSummary,
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 20),

          // Recommendation
          _sectionTitle('Recommendation'),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              scan.recommendation,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );

  // Returns true if the file was actually saved (user didn't cancel).
  Future<bool> saveToDevice(ScanModel scan) async {
    final bytes = await _buildPdfBytes(scan);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save phishing report',
      fileName: _fileName(scan),
      bytes: bytes,
    );
    if (path == null) return false; // user cancelled

    final file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      await file.writeAsBytes(bytes); 
    }
    return true;
  }

  Future<void> shareReport(ScanModel scan) async {
    final bytes = await _buildPdfBytes(scan);
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${_fileName(scan)}';
    final file = File(path);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Phishing analysis report (Risk: ${scan.riskLevel}).',
      subject: 'Bongka Phishing Report',
    );
  }
}
