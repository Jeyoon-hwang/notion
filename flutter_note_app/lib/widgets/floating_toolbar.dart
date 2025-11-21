import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import './ocr_result_dialog.dart';

class FloatingToolbar extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const FloatingToolbar({Key? key, required this.repaintBoundaryKey}) : super(key: key);

  static const List<Color> presetColors = [
    Colors.black,
    Color(0xFFFF3B30),
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFAF52DE),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        return Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: provider.isDarkMode
                          ? [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.5),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: provider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tool buttons
                        _ModernToolButton(
                          icon: Icons.edit,
                          isActive: provider.mode == DrawingMode.pen,
                          onTap: () => provider.setMode(DrawingMode.pen),
                          isDarkMode: provider.isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ModernToolButton(
                          icon: Icons.auto_fix_high_outlined,
                          isActive: provider.mode == DrawingMode.eraser,
                          onTap: () => provider.setMode(DrawingMode.eraser),
                          isDarkMode: provider.isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ModernToolButton(
                          icon: Icons.select_all,
                          isActive: provider.mode == DrawingMode.select,
                          onTap: () => provider.setMode(DrawingMode.select),
                          isDarkMode: provider.isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ModernToolButton(
                          icon: Icons.category_outlined,
                          isActive: provider.mode == DrawingMode.shape,
                          onTap: () => provider.setMode(DrawingMode.shape),
                          isDarkMode: provider.isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ModernToolButton(
                          icon: Icons.text_fields,
                          isActive: provider.mode == DrawingMode.text,
                          onTap: () => provider.setMode(DrawingMode.text),
                          isDarkMode: provider.isDarkMode,
                        ),

                        // Auto-shape toggle (only show when pen mode)
                        if (provider.mode == DrawingMode.pen) ...[
                          const SizedBox(width: 8),
                          _ModernToolButton(
                            icon: Icons.auto_awesome,
                            isActive: provider.autoShapeEnabled,
                            onTap: () => provider.toggleAutoShape(),
                            isDarkMode: provider.isDarkMode,
                            isSmall: true,
                          ),
                        ],

                        // Divider
                        if (provider.selectionRect != null || provider.mode == DrawingMode.pen) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0),
                                      ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Shape conversion & OCR buttons (only show when selection exists)
                        if (provider.selectionRect != null) ...[
                          _ModernActionButton(
                            icon: Icons.auto_fix_high,
                            label: '도형',
                            onTap: () => provider.convertSelectionToShapes(),
                            color: const Color(0xFF5E5CE6),
                            isDarkMode: provider.isDarkMode,
                            isLoading: false,
                          ),
                          const SizedBox(width: 8),
                          _ModernActionButton(
                            icon: Icons.text_snippet,
                            label: '텍스트',
                            onTap: () => _recognizeText(context, provider),
                            color: const Color(0xFF34C759),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                          ),
                          const SizedBox(width: 8),
                          _ModernActionButton(
                            icon: Icons.functions,
                            label: '수식',
                            onTap: () => _recognizeMath(context, provider),
                            color: const Color(0xFF007AFF),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                          ),
                          const SizedBox(width: 8),
                          _ModernActionButton(
                            icon: Icons.auto_awesome,
                            label: 'LaTeX',
                            onTap: () => _convertToLatex(context, provider),
                            color: const Color(0xFFFF9500),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                          ),
                        ],

                        // Color palette (only show when pen mode)
                        if (provider.mode == DrawingMode.pen && provider.selectionRect == null) ...[
                          ...presetColors.map((color) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _ModernColorButton(
                                  color: color,
                                  isSelected: provider.currentColor == color,
                                  onTap: () => provider.setColor(color),
                                  isDarkMode: provider.isDarkMode,
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _recognizeText(BuildContext context, DrawingProvider provider) async {
    final result = await provider.recognizeSelection(repaintBoundaryKey);
    if (result != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => OCRResultDialog(
          text: result['text'],
          isMath: false,
          latex: '',
        ),
      );
      provider.clearSelection();
    }
  }

  Future<void> _recognizeMath(BuildContext context, DrawingProvider provider) async {
    final result = await provider.recognizeSelection(repaintBoundaryKey);
    if (result != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => OCRResultDialog(
          text: result['text'],
          isMath: result['isMath'],
          latex: result['latex'],
        ),
      );
      provider.clearSelection();
    }
  }

  Future<void> _convertToLatex(BuildContext context, DrawingProvider provider) async {
    await provider.convertSelectionToLatex(repaintBoundaryKey);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '손글씨가 LaTeX로 변환되었습니다',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }
}

class _ModernToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool isSmall;

  const _ModernToolButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 40.0 : 48.0;
    final iconSize = isSmall ? 20.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive
              ? null
              : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isActive
              ? Colors.white
              : (isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDarkMode;
  final bool isLoading;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isDarkMode,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ModernColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
