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
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: provider.isDarkMode
                    ? Colors.black.withOpacity(0.98)
                    : Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolButton(
                    icon: '✏️',
                    isActive: provider.mode == DrawingMode.pen,
                    onTap: () => provider.setMode(DrawingMode.pen),
                    isDarkMode: provider.isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  _ToolButton(
                    icon: '🧹',
                    isActive: provider.mode == DrawingMode.eraser,
                    onTap: () => provider.setMode(DrawingMode.eraser),
                    isDarkMode: provider.isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  _ToolButton(
                    icon: '⬚',
                    isActive: provider.mode == DrawingMode.select,
                    onTap: () => provider.setMode(DrawingMode.select),
                    isDarkMode: provider.isDarkMode,
                    label: '선택',
                  ),
                  const SizedBox(width: 12),
                  _ToolButton(
                    icon: '⬡',
                    isActive: provider.mode == DrawingMode.shape,
                    onTap: () => provider.setMode(DrawingMode.shape),
                    isDarkMode: provider.isDarkMode,
                    label: '도형',
                  ),
                  const SizedBox(width: 12),
                  _ToolButton(
                    icon: '⌨',
                    isActive: provider.mode == DrawingMode.text,
                    onTap: () => provider.setMode(DrawingMode.text),
                    isDarkMode: provider.isDarkMode,
                    label: '텍스트',
                  ),

                  // Auto-shape toggle (only show when pen mode)
                  if (provider.mode == DrawingMode.pen) ...[
                    const SizedBox(width: 12),
                    _ToolButton(
                      icon: '✨',
                      isActive: provider.autoShapeEnabled,
                      onTap: () => provider.toggleAutoShape(),
                      isDarkMode: provider.isDarkMode,
                      label: '자동',
                    ),
                  ],

                  const SizedBox(width: 15),
                  _Divider(isDarkMode: provider.isDarkMode),
                  const SizedBox(width: 15),

                  // Shape conversion button (only show when selection exists)
                  if (provider.selectionRect != null) ...[
                    _OCRButton(
                      icon: Icons.auto_fix_high,
                      label: '도형변환',
                      onTap: () => provider.convertSelectionToShapes(),
                      isDarkMode: provider.isDarkMode,
                      isLoading: false,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // OCR buttons (only show when selection exists)
                  if (provider.selectionRect != null) ...[
                    _OCRButton(
                      icon: Icons.text_fields,
                      label: '텍스트',
                      onTap: () => _recognizeText(context, provider),
                      isDarkMode: provider.isDarkMode,
                      isLoading: provider.isProcessingOCR,
                    ),
                    const SizedBox(width: 12),
                    _OCRButton(
                      icon: Icons.calculate,
                      label: '수식',
                      onTap: () => _recognizeMath(context, provider),
                      isDarkMode: provider.isDarkMode,
                      isLoading: provider.isProcessingOCR,
                    ),
                    const SizedBox(width: 15),
                    _Divider(isDarkMode: provider.isDarkMode),
                    const SizedBox(width: 15),
                  ],

                  // Color palette (only show when pen mode)
                  if (provider.mode == DrawingMode.pen) ...[
                    ...presetColors.map((color) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _ColorButton(
                            color: color,
                            isSelected: provider.currentColor == color,
                            onTap: () => provider.setColor(color),
                          ),
                        )),
                    _Divider(isDarkMode: provider.isDarkMode),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => _showColorPicker(context, provider),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: provider.currentColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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

  void _showColorPicker(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              20,
              (index) {
                final color = HSLColor.fromAHSL(
                  1.0,
                  (index * 360 / 20),
                  0.7,
                  0.5,
                ).toColor();
                return GestureDetector(
                  onTap: () {
                    provider.setColor(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;
  final String? label;

  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: label != null ? null : 50,
        height: 50,
        padding: label != null ? const EdgeInsets.symmetric(horizontal: 12) : null,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive
              ? null
              : (isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? const Color(0xFF667EEA) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: label != null
              ? Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                )
              : Text(icon, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

class _OCRButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool isLoading;

  const _OCRButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDarkMode,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF34C759).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
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
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDarkMode;

  const _Divider({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0),
    );
  }
}
