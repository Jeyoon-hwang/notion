import 'package:flutter/material.dart';
import 'dart:async';

/// Focus Mode Overlay
/// Minimal UI for maximum concentration
/// Shows only timer and task name with option to exit
class FocusModeOverlay extends StatefulWidget {
  final String taskName;
  final VoidCallback onExit;
  final Duration initialDuration;

  const FocusModeOverlay({
    Key? key,
    required this.taskName,
    required this.onExit,
    this.initialDuration = Duration.zero,
  }) : super(key: key);

  @override
  State<FocusModeOverlay> createState() => _FocusModeOverlayState();
}

class _FocusModeOverlayState extends State<FocusModeOverlay> {
  late Duration _elapsed;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.initialDuration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.scaffoldBackgroundColor.withOpacity(0.98),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Motivational text
            Text(
              '집중 모드',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),

            // Timer display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.onBackground.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _buildTimeUnit(theme, hours),
                  _buildSeparator(theme),
                  _buildTimeUnit(theme, minutes),
                  _buildSeparator(theme),
                  _buildTimeUnit(theme, seconds),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Task name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.taskName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume button
                _buildControlButton(
                  theme,
                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
                  label: _isPaused ? '계속' : '일시정지',
                  onPressed: _togglePause,
                ),
                const SizedBox(width: 20),

                // Exit button
                _buildControlButton(
                  theme,
                  icon: Icons.close,
                  label: '나가기',
                  onPressed: widget.onExit,
                  isExit: true,
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Motivational quote
            Text(
              '"집중은 성공의 시작이다"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.4),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(ThemeData theme, String value) {
    return Text(
      value,
      style: theme.textTheme.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        height: 1.0,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: theme.textTheme.displayLarge?.copyWith(
          fontSize: 56,
          fontWeight: FontWeight.w300,
          height: 1.0,
          color: theme.colorScheme.onBackground.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isExit = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isExit
              ? theme.colorScheme.onBackground.withOpacity(0.05)
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExit
                ? theme.colorScheme.onBackground.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isExit
                  ? theme.colorScheme.onBackground.withOpacity(0.6)
                  : theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isExit
                    ? theme.colorScheme.onBackground.withOpacity(0.6)
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
