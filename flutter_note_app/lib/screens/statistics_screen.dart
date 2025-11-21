import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/planner.dart';
import '../providers/theme_provider.dart';

/// Statistics and review screen
/// Visualizes study time with beautiful graphs (Gongstagram-worthy)
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planner = context.watch<PlannerManager>();
    final stats = planner.statistics;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '통계 / 리뷰',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '나의 학습 데이터',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overall Stats Cards
            SliverToBoxAdapter(
              child: _buildOverallStats(theme, stats),
            ),

            // Weekly Chart
            SliverToBoxAdapter(
              child: _buildWeeklyChart(theme),
            ),

            // Subject Breakdown
            SliverToBoxAdapter(
              child: _buildSubjectBreakdown(theme),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(ThemeData theme, Map<String, dynamic> stats) {
    final totalStudyTime = stats['totalStudyTime'] as Duration;
    final hours = totalStudyTime.inHours;
    final minutes = totalStudyTime.inMinutes.remainder(60);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              icon: Icons.timer,
              title: '총 학습 시간',
              value: '${hours}h ${minutes}m',
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              icon: Icons.check_circle,
              title: '완료한 과제',
              value: '${stats['completed']}개',
              color: const Color(0xFF34C759),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(ThemeData theme) {
    // Mock data for weekly study hours (would be real data in production)
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final studyHours = [3.5, 4.2, 2.8, 5.1, 6.0, 4.5, 3.2];
    final maxHours = studyHours.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 학습 시간',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Bar chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final height = (studyHours[index] / maxHours) * 120;
              return _buildBarColumn(
                theme,
                weekDays[index],
                height,
                studyHours[index],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(
    ThemeData theme,
    String label,
    double height,
    double hours,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hours label
        Text(
          '${hours.toStringAsFixed(1)}h',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Bar
        Container(
          width: 32,
          height: height.clamp(20.0, 120.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        // Day label
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBreakdown(ThemeData theme) {
    // Mock data for subjects (would be real data in production)
    final subjects = [
      SubjectData('수학', 13.0, 20.0, const Color(0xFFFF6B6B)),
      SubjectData('영어', 9.0, 20.0, const Color(0xFF4ECDC4)),
      SubjectData('국어', 6.0, 20.0, const Color(0xFFFFE66D)),
      SubjectData('과학', 8.5, 20.0, const Color(0xFF95E1D3)),
      SubjectData('사회', 4.2, 20.0, const Color(0xFFAA96DA)),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '과목별 학습 시간',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...subjects.map((subject) => _buildSubjectRow(theme, subject)),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(ThemeData theme, SubjectData subject) {
    final percentage = (subject.hours / subject.maxHours * 100).clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${subject.hours.toStringAsFixed(1)}시간',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: subject.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.onBackground.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(subject.color),
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectData {
  final String name;
  final double hours;
  final double maxHours;
  final Color color;

  SubjectData(this.name, this.hours, this.maxHours, this.color);
}
