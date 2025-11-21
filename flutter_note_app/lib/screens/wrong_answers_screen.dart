import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wrong_answer.dart';
import '../models/practice_session.dart';

/// Wrong answers screen with N회독 (multiple review rounds) support
/// Clean, minimal design for Gongstagram aesthetics
class WrongAnswersScreen extends StatefulWidget {
  const WrongAnswersScreen({Key? key}) : super(key: key);

  @override
  State<WrongAnswersScreen> createState() => _WrongAnswersScreenState();
}

class _WrongAnswersScreenState extends State<WrongAnswersScreen> {
  int _selectedRound = 1; // Current session (1회독, 2회독, etc.)

  // Mock data - would be real data in production
  final List<WrongAnswer> _mockWrongAnswers = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      '오답 노트',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '틀린 문제로 완벽하게 마스터하기',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Round selector (N회독)
            SliverToBoxAdapter(
              child: _buildRoundSelector(theme),
            ),

            // Statistics for current round
            SliverToBoxAdapter(
              child: _buildRoundStatistics(theme),
            ),

            // Wrong answers list
            if (_mockWrongAnswers.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(theme),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final wrongAnswer = _mockWrongAnswers[index];
                    return _buildWrongAnswerCard(theme, wrongAnswer);
                  },
                  childCount: _mockWrongAnswers.length,
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open PDF to clip wrong answer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('오답 추가 기능 (노트에서 클립)')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('오답 추가'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildRoundSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final round = index + 1;
          final isSelected = _selectedRound == round;
          final color = PracticeSessionManager.sessionColors[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRound = round;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  '$round회독',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoundStatistics(ThemeData theme) {
    // Mock statistics - would be real data in production
    final totalProblems = 15;
    final masteredProblems = 8;
    final remainingProblems = totalProblems - masteredProblems;
    final masteryPercent = (masteredProblems / totalProblems * 100).toInt();

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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.quiz,
                  label: '전체 문제',
                  value: '$totalProblems',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.check_circle,
                  label: '마스터',
                  value: '$masteredProblems',
                  color: const Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.pending,
                  label: '남은 문제',
                  value: '$remainingProblems',
                  color: const Color(0xFFFF9500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: masteryPercent / 100,
              minHeight: 12,
              backgroundColor: theme.colorScheme.onBackground.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF34C759),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마스터율: $masteryPercent%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWrongAnswerCard(ThemeData theme, WrongAnswer wrongAnswer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
        ),
        title: Text(
          wrongAnswer.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: wrongAnswer.difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    wrongAnswer.difficulty == DifficultyLevel.easy
                        ? '쉬움'
                        : wrongAnswer.difficulty == DifficultyLevel.medium
                            ? '보통'
                            : '어려움',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: wrongAnswer.difficultyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  wrongAnswer.reviewStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: wrongAnswer.isMastered
            ? const Icon(Icons.check_circle, color: Color(0xFF34C759))
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Open wrong answer detail/solve screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오답 보기: ${wrongAnswer.title}')),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            '아직 오답이 없습니다',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '문제를 풀면서 틀린 문제를 추가하세요\n노트에서 문제 영역을 클립하여 오답 노트에 추가할 수 있습니다',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
