import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';

class AppHeader extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const AppHeader({Key? key, required this.repaintBoundaryKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: provider.isDarkMode
                ? Colors.black.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('✏️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Digital Note',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: provider.isDarkMode
                            ? const Color(0xFF8B9CFF)
                            : const Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _IconButton(
                      icon: '↶',
                      onTap: provider.canUndo ? provider.undo : null,
                      isDarkMode: provider.isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    _IconButton(
                      icon: '↷',
                      onTap: provider.canRedo ? provider.redo : null,
                      isDarkMode: provider.isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    _IconButton(
                      icon: '🗑️',
                      onTap: () => _showClearDialog(context, provider),
                      isDarkMode: provider.isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    _IconButton(
                      icon: '💾',
                      onTap: () => provider.saveImage(repaintBoundaryKey),
                      isDarkMode: provider.isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    _IconButton(
                      icon: provider.isDarkMode ? '☀️' : '🌙',
                      onTap: provider.toggleDarkMode,
                      isDarkMode: provider.isDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 지우기'),
        content: const Text('모든 내용을 지우시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              provider.clear();
              Navigator.pop(context);
            },
            child: const Text('지우기'),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
