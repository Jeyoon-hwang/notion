import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/drawing_stroke.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../services/ocr_service.dart';

enum DrawingMode { pen, eraser, select }

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
  DrawingMode _mode = DrawingMode.pen;
  bool _isDarkMode = false;

  // Selection
  Rect? _selectionRect;
  Offset? _selectionStart;
  bool _isSelecting = false;

  // OCR
  final OCRService _ocrService = OCRService();
  bool _isProcessingOCR = false;

  // Getters
  List<DrawingStroke> get strokes => _strokes;
  Color get currentColor => _currentColor;
  double get lineWidth => _lineWidth;
  double get opacity => _opacity;
  DrawingMode get mode => _mode;
  bool get isEraser => _mode == DrawingMode.eraser;
  bool get isSelectMode => _mode == DrawingMode.select;
  bool get isDarkMode => _isDarkMode;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  Rect? get selectionRect => _selectionRect;
  bool get isProcessingOCR => _isProcessingOCR;

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

  void setMode(DrawingMode mode) {
    _mode = mode;
    _selectionRect = null;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Drawing methods
  void startDrawing(Offset offset, double pressure) {
    if (_mode == DrawingMode.select) {
      _selectionStart = offset;
      _isSelecting = true;
      _selectionRect = null;
      notifyListeners();
      return;
    }

    _currentStroke.clear();
    _currentStroke.add(DrawingPoint(offset: offset, pressure: pressure));
    notifyListeners();
  }

  void updateDrawing(Offset offset, double pressure) {
    if (_mode == DrawingMode.select && _isSelecting && _selectionStart != null) {
      _selectionRect = Rect.fromPoints(_selectionStart!, offset);
      notifyListeners();
      return;
    }

    _currentStroke.add(DrawingPoint(offset: offset, pressure: pressure));
    notifyListeners();
  }

  void endDrawing() {
    if (_mode == DrawingMode.select) {
      _isSelecting = false;
      notifyListeners();
      return;
    }

    if (_currentStroke.isNotEmpty) {
      final stroke = DrawingStroke(
        points: List.from(_currentStroke),
        color: _currentColor,
        width: _lineWidth,
        opacity: _opacity,
        isEraser: _mode == DrawingMode.eraser,
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

  void clearSelection() {
    _selectionRect = null;
    _selectionStart = null;
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

  Future<Map<String, dynamic>?> recognizeSelection(GlobalKey repaintBoundaryKey) async {
    if (_selectionRect == null) return null;

    _isProcessingOCR = true;
    notifyListeners();

    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      // Get full canvas image
      ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
      
      // Crop to selection
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      canvas.drawImageRect(
        fullImage,
        _selectionRect!,
        Rect.fromLTWH(0, 0, _selectionRect!.width, _selectionRect!.height),
        Paint(),
      );
      
      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(
        _selectionRect!.width.toInt(),
        _selectionRect!.height.toInt(),
      );

      // Process with OCR
      final result = await _ocrService.processHandwriting(croppedImage);
      
      _isProcessingOCR = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      print('Error recognizing text: $e');
      _isProcessingOCR = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
