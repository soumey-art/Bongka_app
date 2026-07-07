class ReportModel {
  final int totalScans;
  final int daysActive;
  final int accuracy;
  final List<int> weeklyData; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]

  ReportModel({
    required this.totalScans,
    required this.daysActive,
    required this.accuracy,
    required this.weeklyData,
  });
}
