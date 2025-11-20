import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/drawing_stroke.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DrawingProvider extends ChangeNotifier {
  final List<DrawingStroke> _strokes = [];
  final List<List<DrawingStroke>> _history = [];
  int _historyIndex = -1;
  final int _maxHistory = 50;

  DrawingPoint? _currentPoint;
  final List<DrawingPoint> _currentStroke = [];

  // Drawing settings
  Color _currentColor = Colors.black;
  double _lineWidth = 3.0;
  double _opacity = 1.0;
  bool _isEraser = false;
  bool _isDarkMode = false;

  // Getters
  List<DrawingStroke> get strokes => _strokes;
  Color get currentColor => _currentColor;
  double get lineWidth => _lineWidth;
  double get opacity => _opacity;
  bool get isEraser => _isEraser;
  bool get isDarkMode => _isDarkMode;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  // Setters
  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void setLineWidth(double width) {
    _lineWidth = width;
    notifyListeners();
  }

  void setOpacity(double opacity) {
    _opacity = opacity;
    notifyListeners();
  }

  void setTool(bool isEraser) {
    _isEraser = isEraser;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Drawing methods
  void startDrawing(Offset offset, double pressure) {
    _currentStroke.clear();
    _currentStroke.add(DrawingPoint(offset: offset, pressure: pressure));
    notifyListeners();
  }

  void updateDrawing(Offset offset, double pressure) {
    _currentStroke.add(DrawingPoint(offset: offset, pressure: pressure));
    notifyListeners();
  }

  void endDrawing() {
    if (_currentStroke.isNotEmpty) {
      final stroke = DrawingStroke(
        points: List.from(_currentStroke),
        color: _currentColor,
        width: _lineWidth,
        opacity: _opacity,
        isEraser: _isEraser,
      );
      _strokes.add(stroke);
      _saveState();
      _currentStroke.clear();
    }
    notifyListeners();
  }

  List<DrawingPoint> get currentStroke => _currentStroke;

  void _saveState() {
    _historyIndex++;
    if (_historyIndex < _history.length) {
      _history.removeRange(_historyIndex, _history.length);
    }
    _history.add(List.from(_strokes));
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void undo() {
    if (canUndo) {
      _historyIndex--;
      _strokes.clear();
      _strokes.addAll(_history[_historyIndex]);
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _strokes.clear();
      _strokes.addAll(_history[_historyIndex]);
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    _saveState();
    notifyListeners();
  }

  Future<void> saveImage(GlobalKey repaintBoundaryKey) async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: 'note_${DateTime.now().millisecondsSinceEpoch}',
        );
        print('Image saved: $result');
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }
}
