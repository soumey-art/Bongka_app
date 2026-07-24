import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../../provider/scan_provider.dart';
import '../../../model/scan_model.dart';
import '../analyzer/phishing_detector_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Key _reportsKey = UniqueKey();

  void _goToTab(int index) {
    setState(() {
      if (index == 1) _reportsKey = UniqueKey();
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onViewReports: () => _goToTab(1)),
      ReportsScreen(key: _reportsKey),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceColor,
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({required this.onViewReports});
  final VoidCallback onViewReports;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // Only kept local since it's derived from the user's score, not a scan.
  ({String label, Color color}) _overallRisk(int score) {
    if (score >= 80) return (label: 'Low Risk', color: AppColors.greenColor);
    if (score >= 50)
      return (label: 'Moderate Risk', color: AppColors.yellowColor);
    return (label: 'High Risk', color: AppColors.redColor);
  }

  Future<void> _refreshScore() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final newScore = await context.read<ScanProvider>().getSavedScore(userId);
    if (newScore != null && mounted) {
      context.read<AuthProvider>().updateLocalScore(newScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final score = user?.cyberSafetyScore ?? 100;
    final userId = user?.id ?? '';

    return RefreshIndicator(
      color: AppColors.blueColor,
      onRefresh: _refreshScore,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _greeting(user?.displayName ?? ''),
          const SizedBox(height: 20),
          _scoreCard(score),
          const SizedBox(height: 16),
          _actionCards(context),
          const SizedBox(height: 24),
          _recentActivityHeader(),
          const SizedBox(height: 12),
          _recentActivity(userId),
          const SizedBox(height: 8),
          _tipOfTheDay(),
        ],
      ),
    );
  }

  Widget _greeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back,',
          style: TextStyles.smallStyle.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              name.isNotEmpty ? name : 'there',
              style: TextStyles.titleStyle,
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
      ],
    );
  }

  Widget _scoreCard(int score) {
    final risk = _overallRisk(score);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: AppColors.surfaceBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.blueColor),
                ),
                Text(
                  '$score%',
                  style: TextStyles.bodyStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cyber Safety Score',
                  style: TextStyles.smallStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: risk.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    risk.label,
                    style: TextStyles.smallStyle.copyWith(
                      color: risk.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.mail_outline,
            title: 'Scan Message',
            subtitle: 'Detect phishing',
            filled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhishingDetectorScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.bar_chart_outlined,
            title: 'View Reports',
            subtitle: 'Your history',
            filled: false,
            onTap: widget.onViewReports,
          ),
        ),
      ],
    );
  }

  Widget _recentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        GestureDetector(
          onTap: widget.onViewReports,
          child: Text(
            'See all',
            style: TextStyles.smallStyle.copyWith(
              color: AppColors.blueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _recentActivity(String userId) {
    return StreamBuilder<List<ScanModel>>(
      stream: context.read<ScanProvider>().recentScansStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return _activityCard(_loadingRow());
        if (snapshot.hasError) return _activityCard(_errorText());

        final scans = snapshot.data ?? [];
        if (scans.isEmpty) return _activityCard(_emptyState());

        return Column(children: scans.map(_scanTile).toList());
      },
    );
  }

  Widget _activityCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _loadingRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.blueColor,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Loading activity...',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _errorText() {
    return Text(
      'Could not load activity.',
      style: TextStyles.smallStyle.copyWith(color: AppColors.textMuted),
    );
  }

  Widget _emptyState() {
    return Column(
      children: [
        const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 32),
        const SizedBox(height: 8),
        Text(
          'No scans yet',
          style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap Scan Message to analyze your first email',
          style: TextStyles.smallStyle.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _scanTile(ScanModel scan) {
    final color = scan.riskColor;
    final text = scan.messageText.length > 35
        ? '${scan.messageText.substring(0, 35)}...'
        : scan.messageText;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            scan.riskLevel == 'SAFE'
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodyStyle.copyWith(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              scan.riskLabel,
              style: TextStyles.smallStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipOfTheDay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blueColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.blueColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Tip of the Day',
                style: TextStyles.smallStyle.copyWith(
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hover links before clicking — the real URL shows in your browser status bar.',
            style: TextStyles.bodyStyle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.blueColor : AppColors.surfaceColor;
    final fg = filled ? AppColors.blueDark : AppColors.textColor;
    final subFg = filled
        ? AppColors.blueDark.withValues(alpha: 0.7)
        : AppColors.textMuted;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyles.bodyStyle.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyles.smallStyle.copyWith(color: subFg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
