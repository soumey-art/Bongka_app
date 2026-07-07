import 'package:flutter/material.dart';
import '../model/scan_model.dart';

/// Placeholder scan provider so the app compiles. Wire this up to
/// PhishingRepository / ScanModel once the analyzer screens are built.
class ScanProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  bool isLoading = false;
}
