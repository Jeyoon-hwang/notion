import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../providers/drawing_provider.dart';
import '../models/drawing_stroke.dart';
import '../models/text_object.dart';
import '../widgets/text_input_dialog.dart';

/// Intelligently inverts colors for dark mode (text version)
Color _invertColorForText(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final invertedLightness = 1.0 - hslColor.lightness;
  final adjustedLightness = invertedLightness < 0.6
      ? 0.6 + (invertedLightness * 0.4)
      : invertedLightness;
  final adjustedSaturation = hslColor.saturation > 0.8
      ? hslColor.saturation * 0.85
      : hslColor.saturation;
  return hslColor
      .withLightness(adjustedLightness)
      .withSaturation(adjustedSaturation)
      .toColor();
}

class DrawingCanvas extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const DrawingCanvas({Key? key, required this.repaintBoundaryKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Show text input dialog when text input position is set
        if (provider.textInputPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => const TextInputDialog(),
            );
          });
        }

        return Stack(
          children: [
            Listener(
              onPointerDown: (event) {
                provider.startDrawing(
                  event.localPosition,
                  event.pressure,
                  isPen: event.kind == PointerDeviceKind.stylus,
                );
              },
              onPointerMove: (event) {
                provider.updateDrawing(
                  event.localPosition,
                  event.pressure,
                );
              },
              onPointerUp: (event) {
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
                    shapePreview: provider.isShapeMode ? provider.getShapePreview() : [],
                    showGridLines: provider.settings.showGridLines,
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
            ),
            // Text objects overlay
            ...provider.textObjects.map((textObj) => Positioned(
              left: textObj.position.dx,
              top: textObj.position.dy,
              child: GestureDetector(
                onTap: () => provider.selectTextObject(textObj),
                onPanUpdate: (details) {
                  provider.moveTextObject(
                    textObj.id,
                    textObj.position + details.delta,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.selectedTextObject?.id == textObj.id
                        ? const Color(0xFF667EEA).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: provider.selectedTextObject?.id == textObj.id
                        ? Border.all(color: const Color(0xFF667EEA), width: 2)
                        : null,
                  ),
                  child: textObj.type == TextType.latex
                      ? Math.tex(
                          textObj.text,
                          textStyle: TextStyle(
                            fontSize: textObj.fontSize,
                            color: provider.isDarkMode
                                ? _invertColorForText(textObj.color)
                                : textObj.color,
                          ),
                        )
                      : Text(
                          textObj.text,
                          style: TextStyle(
                            fontSize: textObj.fontSize,
                            color: provider.isDarkMode
                                ? _invertColorForText(textObj.color)
                                : textObj.color,
                          ),
                        ),
                ),
              ),
            )),
            // Selection overlay
            if (provider.selectionRect != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SelectionPainter(
                    selectionRect: provider.selectionRect!,
                  ),
                ),
              ),
          ],
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
  final List<DrawingPoint> shapePreview;
  final bool showGridLines;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.lineWidth,
    required this.opacity,
    required this.isEraser,
    required this.isDarkMode,
    this.shapePreview = const [],
    this.showGridLines = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines if enabled
    if (showGridLines) {
      _drawGridLines(canvas, size);
    }

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

    // Draw shape preview
    if (shapePreview.isNotEmpty) {
      final previewStroke = DrawingStroke(
        points: shapePreview,
        color: currentColor,
        width: lineWidth,
        opacity: opacity * 0.6, // Slightly transparent for preview
        isEraser: false,
      );
      _drawStroke(canvas, previewStroke);
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
          : (isDarkMode
              ? _invertColorIntelligently(stroke.color).withOpacity(stroke.opacity)
              : stroke.color.withOpacity(stroke.opacity));
      paint.strokeWidth = adjustedWidth;

      canvas.drawLine(point1.offset, point2.offset, paint);
    }
  }

  /// Intelligently inverts colors for dark mode
  /// - Black → White
  /// - Dark colors → Light versions
  /// - Preserves hue, inverts lightness
  Color _invertColorIntelligently(Color color) {
    // Convert to HSL
    final hslColor = HSLColor.fromColor(color);

    // Invert lightness: dark becomes light, light becomes dark
    // We use a complementary lightness calculation
    final invertedLightness = 1.0 - hslColor.lightness;

    // Boost lightness to ensure visibility on dark background
    // Minimum lightness of 0.6 to keep colors bright
    final adjustedLightness = invertedLightness < 0.6 ? 0.6 + (invertedLightness * 0.4) : invertedLightness;

    // Slightly reduce saturation for very saturated colors to avoid eye strain
    final adjustedSaturation = hslColor.saturation > 0.8
        ? hslColor.saturation * 0.85
        : hslColor.saturation;

    return hslColor
        .withLightness(adjustedLightness)
        .withSaturation(adjustedSaturation)
        .toColor();
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.shapePreview != shapePreview ||
        oldDelegate.showGridLines != showGridLines ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

class SelectionPainter extends CustomPainter {
  final Rect selectionRect;

  SelectionPainter({required this.selectionRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw selection background
    final bgPaint = Paint()
      ..color = const Color(0xFF667EEA).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(selectionRect, bgPaint);

    // Draw selection border
    final borderPaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Dashed border
    final path = Path()
      ..addRect(selectionRect);
    
    canvas.drawPath(_createDashedPath(path, 8, 4), borderPaint);

    // Draw corner handles
    final handlePaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..style = PaintingStyle.fill;
    
    final handleSize = 8.0;
    final corners = [
      selectionRect.topLeft,
      selectionRect.topRight,
      selectionRect.bottomLeft,
      selectionRect.bottomRight,
    ];

    for (var corner in corners) {
      canvas.drawCircle(corner, handleSize, handlePaint);
      canvas.drawCircle(
        corner,
        handleSize,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Path _createDashedPath(Path source, double dashLength, double dashSpace) {
    final Path dest = Path();
    for (PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}
