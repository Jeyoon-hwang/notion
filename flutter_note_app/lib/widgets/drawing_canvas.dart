import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/drawing_stroke.dart';

class DrawingCanvas extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const DrawingCanvas({Key? key, required this.repaintBoundaryKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onPanStart: (details) {
            provider.startDrawing(
              details.localPosition,
              details.pressure,
            );
          },
          onPanUpdate: (details) {
            provider.updateDrawing(
              details.localPosition,
              details.pressure,
            );
          },
          onPanEnd: (details) {
            provider.endDrawing();
          },
          child: RepaintBoundary(
            key: repaintBoundaryKey,
            child: CustomPaint(
              painter: DrawingPainter(
                strokes: provider.strokes,
                currentStroke: provider.currentStroke,
                currentColor: provider.currentColor,
                lineWidth: provider.lineWidth,
                opacity: provider.opacity,
                isEraser: provider.isEraser,
                isDarkMode: provider.isDarkMode,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: provider.isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> currentStroke;
  final Color currentColor;
  final double lineWidth;
  final double opacity;
  final bool isEraser;
  final bool isDarkMode;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.lineWidth,
    required this.opacity,
    required this.isEraser,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (currentStroke.isNotEmpty) {
      final currentStrokeData = DrawingStroke(
        points: currentStroke,
        color: currentColor,
        width: lineWidth,
        opacity: opacity,
        isEraser: isEraser,
      );
      _drawStroke(canvas, currentStrokeData);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final point1 = stroke.points[i];
      final point2 = stroke.points[i + 1];

      final pressure = (point1.pressure + point2.pressure) / 2;
      final adjustedWidth = stroke.isEraser
          ? stroke.width * 3
          : stroke.width * (0.5 + pressure);

      paint.color = stroke.isEraser
          ? (isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white)
          : stroke.color.withOpacity(stroke.opacity);
      paint.strokeWidth = adjustedWidth;

      canvas.drawLine(point1.offset, point2.offset, paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
