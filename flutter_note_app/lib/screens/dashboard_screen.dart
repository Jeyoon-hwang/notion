import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/planner.dart';
import '../providers/theme_provider.dart';
import 'gongstagram_settings_screen.dart';
import 'dart:async';

/// Gongstagram-inspired dashboard home screen
/// Center of the app - "Today's Plan" focused
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  Duration _todayStudyTime = Duration.zero;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateTodayStudyTime();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  void _updateTodayStudyTime() {
    final planner = context.read<PlannerManager>();
    final todos = planner.todos;

    _todayStudyTime = todos.fold<Duration>(
      Duration.zero,
      (sum, todo) => sum + todo.currentElapsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planner = context.watch<PlannerManager>();
    final now = DateTime.now();

    // Calculate weekly progress (assuming 40 hours goal)
    const weeklyGoalHours = 40;
    final weeklyProgressPercent =
        (_todayStudyTime.inMinutes / (weeklyGoalHours * 60) * 100)
            .clamp(0, 100);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Minimal Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 계획',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(now),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GongstagramSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Today's Study Time Widget (순공 시간)
            SliverToBoxAdapter(
              child: _buildStudyTimeWidget(theme),
            ),

            // Weekly Goal Progress
            SliverToBoxAdapter(
              child: _buildWeeklyGoalWidget(theme, weeklyProgressPercent),
            ),

            // Today's Task List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '오늘 할 일',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Add Task Input
            SliverToBoxAdapter(
              child: _buildAddTaskInput(theme, planner),
            ),

            // Task List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final todo = planner.todos[index];
                  return _buildTaskItem(theme, planner, todo);
                },
                childCount: planner.todos.length,
              ),
            ),

            // Empty state
            if (planner.todos.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(theme),
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

  Widget _buildStudyTimeWidget(ThemeData theme) {
    final hours = _todayStudyTime.inHours;
    final minutes = _todayStudyTime.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
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
          Text(
            '오늘의 순공 시간',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hours',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '시간',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$minutes',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '분',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timer control (if any active)
          Consumer<PlannerManager>(
            builder: (context, planner, _) {
              if (planner.activeTimerTodo != null) {
                return _buildActiveTimerControl(theme, planner);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimerControl(ThemeData theme, PlannerManager planner) {
    final activeTodo = planner.activeTimerTodo!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activeTodo.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => planner.stopTimer(activeTodo.id),
            child: const Text('정지'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalWidget(ThemeData theme, double progressPercent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            '이번 주 목표 달성률',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 12,
              backgroundColor: theme.colorScheme.onBackground.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progressPercent.toStringAsFixed(1)}%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '목표: 주 40시간',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskInput(ThemeData theme, PlannerManager planner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: '새 과제 추가...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onBackground.withOpacity(0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onBackground.withOpacity(0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  planner.createTodo(
                    title: value.trim(),
                    dueDate: DateTime.now(),
                  );
                  _taskController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_taskController.text.trim().isNotEmpty) {
                planner.createTodo(
                  title: _taskController.text.trim(),
                  dueDate: DateTime.now(),
                );
                _taskController.clear();
              }
            },
            icon: Icon(
              Icons.add_circle,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    ThemeData theme,
    PlannerManager planner,
    TodoItem todo,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => planner.toggleComplete(todo.id),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          todo.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? theme.colorScheme.onBackground.withOpacity(0.4)
                : null,
          ),
        ),
        subtitle: todo.studyTime.inSeconds > 0
            ? Text(
                todo.formattedStudyTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer button
            if (!todo.isCompleted)
              IconButton(
                icon: Icon(
                  todo.isTimerRunning ? Icons.pause : Icons.play_arrow,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  if (todo.isTimerRunning) {
                    planner.stopTimer(todo.id);
                  } else {
                    planner.startTimer(todo.id);
                  }
                },
              ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onBackground.withOpacity(0.3),
              ),
              onPressed: () => planner.deleteTodo(todo.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 과제가 없습니다',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '위에서 새 과제를 추가하세요',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }
}
