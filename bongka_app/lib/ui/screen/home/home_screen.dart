import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../analyzer/phishing_detector_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

/// The signed-in shell: bottom nav across Home / Reports / Settings,
/// matching the approved dashboard mockup.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onViewReports: () => _goToTab(1)),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: Colors.grey,
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

/// A single row in the "Recent Activity" list.
class _ActivityItem {
  final String title;
  final _RiskLevel risk;
  final String timeAgo;

  const _ActivityItem(this.title, this.risk, this.timeAgo);
}

enum _RiskLevel { high, medium, safe }

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onViewReports});

  final VoidCallback onViewReports;

  // TODO: replace with real data from report_repository.dart once
  // scan history is wired up. Kept here as a single source so the
  // "threats detected" count below stays consistent with the list.
  static const List<_ActivityItem> _mockActivity = [
    _ActivityItem('Suspicious PayPal email', _RiskLevel.high, '2h ago'),
    _ActivityItem('Bank OTP verification', _RiskLevel.medium, 'Yesterday'),
    _ActivityItem('Newsletter — Shopee', _RiskLevel.safe, '2d ago'),
  ];

  Color _riskColor(_RiskLevel risk) {
    switch (risk) {
      case _RiskLevel.high:
        return AppColors.redColor;
      case _RiskLevel.medium:
        return AppColors.yellowColor;
      case _RiskLevel.safe:
        return AppColors.greenColor;
    }
  }

  String _riskLabel(_RiskLevel risk) {
    switch (risk) {
      case _RiskLevel.high:
        return 'HIGH';
      case _RiskLevel.medium:
        return 'MED';
      case _RiskLevel.safe:
        return 'SAFE';
    }
  }

  ({String label, Color color}) _overallRisk(int score) {
    if (score >= 80) return (label: 'Low Risk', color: AppColors.greenColor);
    if (score >= 50) {
      return (label: 'Moderate Risk', color: AppColors.yellowColor);
    }
    return (label: 'High Risk', color: AppColors.redColor);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final score = user?.cyberSafetyScore ?? 100;
    final risk = _overallRisk(score);
    final threatsThisWeek = _mockActivity
        .where((a) => a.risk != _RiskLevel.safe)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Greeting
        Text('Welcome Back,', style: TextStyles.smallStyle),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              user?.displayName.isNotEmpty == true
                  ? user!.displayName
                  : 'there',
              style: TextStyles.titleStyle,
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),

        const SizedBox(height: 20),

        // Cyber Safety Score card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 7,
                        backgroundColor: const Color(0xFFE9EEF6),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blueColor,
                        ),
                      ),
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
                    Text('Cyber Safety Score', style: TextStyles.smallStyle),
                    const SizedBox(height: 2),
                    Text(
                      '$threatsThisWeek threat${threatsThisWeek == 1 ? '' : 's'} detected this week',
                      style: TextStyles.smallStyle,
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
        ),

        const SizedBox(height: 16),

        // Action cards
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.mail_outline,
                title: 'Analyze Message',
                subtitle: 'Detect phishing',
                filled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhishingDetectorScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.bar_chart_outlined,
                title: 'View Reports',
                subtitle: 'Your history',
                filled: false,
                onTap: onViewReports,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Recent Activity header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: onViewReports,
              child: Text(
                'See all',
                style: TextStyles.smallStyle.copyWith(
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._mockActivity.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item.risk == _RiskLevel.safe
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  color: _riskColor(item.risk),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyles.bodyStyle.copyWith(fontSize: 14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _riskColor(item.risk).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _riskLabel(item.risk),
                        style: TextStyles.smallStyle.copyWith(
                          color: _riskColor(item.risk),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeAgo,
                      style: TextStyles.smallStyle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tip of the Day
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
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
                style: TextStyles.bodyStyle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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
    final Color bg = filled ? AppColors.blueColor : Colors.white;
    final Color fg = filled ? Colors.white : AppColors.textColor;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
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
                style: TextStyles.smallStyle.copyWith(
                  color: filled ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
