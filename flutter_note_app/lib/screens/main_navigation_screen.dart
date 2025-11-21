import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notes_list_screen.dart';
import 'wrong_answers_screen.dart';
import 'statistics_screen.dart';

/// Main navigation screen with bottom tab bar
/// Gongstagram-inspired minimal design
/// Tabs: [Today's Plan] - [Notes] - [Wrong Answers] - [Statistics]
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(), // 오늘의 계획
    NotesListScreen(), // 노트 탐색
    WrongAnswersScreen(), // 오답 노트
    StatisticsScreen(), // 통계/리뷰
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onBackground.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                theme,
                index: 0,
                icon: Icons.calendar_today,
                label: '오늘의 계획',
              ),
              _buildNavItem(
                theme,
                index: 1,
                icon: Icons.book,
                label: '노트 탐색',
              ),
              _buildNavItem(
                theme,
                index: 2,
                icon: Icons.error_outline,
                label: '오답 노트',
              ),
              _buildNavItem(
                theme,
                index: 3,
                icon: Icons.bar_chart,
                label: '통계/리뷰',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    ThemeData theme, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onBackground.withOpacity(0.5);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: isSelected ? 26 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
