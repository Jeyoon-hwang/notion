import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/drawing_stroke.dart';
import '../models/text_object.dart';
import '../models/app_settings.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../services/ocr_service.dart';
import '../services/shape_recognition_service.dart';
import '../services/shape_drawing_service.dart';

enum DrawingMode { pen, eraser, select, shape, text }

class DrawingProvider extends ChangeNotifier {
  final List<DrawingStroke> _strokes = [];
  final List<TextObject> _textObjects = [];
  final List<List<DrawingStroke>> _history = [];
  int _historyIndex = -1;
  final int _maxHistory = 50;

  DrawingPoint? _currentPoint;
  final List<DrawingPoint> _currentStroke = [];

  // App settings
  AppSettings _settings = AppSettings();

  // Drawing settings
  Color _currentColor = Colors.black;
  double _lineWidth = 3.0;
  double _opacity = 1.0;
  DrawingMode _mode = DrawingMode.pen;
  bool _isDarkMode = false;
  bool _autoShapeEnabled = false;

  // Text input
  Offset? _textInputPosition;
  TextObject? _selectedTextObject;

  // Selection
  Rect? _selectionRect;
  Offset? _selectionStart;
  bool _isSelecting = false;

  // Services
  final OCRService _ocrService = OCRService();
  final ShapeRecognitionService _shapeService = ShapeRecognitionService();
  final ShapeDrawingService _shapeDrawingService = ShapeDrawingService();
  bool _isProcessingOCR = false;

  // Shape drawing
  ShapeType2D _selectedShape2D = ShapeType2D.circle;
  ShapeType3D? _selectedShape3D;
  double _shapeSize = 100.0;
  double _triangleAngle1 = 60.0;
  double _triangleAngle2 = 60.0;
  double _triangleAngle3 = 60.0;
  Offset? _shapeStartPoint;

  // Getters
  List<DrawingStroke> get strokes => _strokes;
  List<TextObject> get textObjects => _textObjects;
  AppSettings get settings => _settings;
  Color get currentColor => _currentColor;
  double get lineWidth => _lineWidth;
  double get opacity => _opacity;
  DrawingMode get mode => _mode;
  bool get isEraser => _mode == DrawingMode.eraser;
  bool get isSelectMode => _mode == DrawingMode.select;
  bool get isDarkMode => _isDarkMode;
  bool get autoShapeEnabled => _autoShapeEnabled;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  Rect? get selectionRect => _selectionRect;
  bool get isProcessingOCR => _isProcessingOCR;
  ShapeType2D get selectedShape2D => _selectedShape2D;
  ShapeType3D? get selectedShape3D => _selectedShape3D;
  double get shapeSize => _shapeSize;
  double get triangleAngle1 => _triangleAngle1;
  double get triangleAngle2 => _triangleAngle2;
  double get triangleAngle3 => _triangleAngle3;
  bool get isShapeMode => _mode == DrawingMode.shape;
  bool get isTextMode => _mode == DrawingMode.text;
  Offset? get textInputPosition => _textInputPosition;
  TextObject? get selectedTextObject => _selectedTextObject;
  bool get palmRejection => _settings.palmRejection;

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

  void toggleAutoShape() {
    _autoShapeEnabled = !_autoShapeEnabled;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setShape2D(ShapeType2D shape) {
    _selectedShape2D = shape;
    _selectedShape3D = null;
    notifyListeners();
  }

  void setShape3D(ShapeType3D shape) {
    _selectedShape3D = shape;
    notifyListeners();
  }

  void setShapeSize(double size) {
    _shapeSize = size;
    notifyListeners();
  }

  void setTriangleAngles(double angle1, double angle2, double angle3) {
    _triangleAngle1 = angle1;
    _triangleAngle2 = angle2;
    _triangleAngle3 = angle3;
    notifyListeners();
  }

  // Drawing methods
  void startDrawing(Offset offset, double pressure, {bool isPen = false}) {
    // Palm rejection: ignore if palm rejection is enabled and input is not from pen
    if (_settings.palmRejection && !isPen && _mode == DrawingMode.pen) {
      return;
    }

    if (_mode == DrawingMode.select) {
      _selectionStart = offset;
      _isSelecting = true;
      _selectionRect = null;
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.shape) {
      _shapeStartPoint = offset;
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.text) {
      startTextInput(offset);
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

    if (_mode == DrawingMode.shape && _shapeStartPoint != null) {
      // Update shape preview based on drag
      _shapeSize = (offset - _shapeStartPoint!).distance;
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

    if (_mode == DrawingMode.shape && _shapeStartPoint != null) {
      // Create the shape
      List<DrawingPoint> shapePoints = [];

      if (_selectedShape3D != null) {
        // Draw 3D shape
        switch (_selectedShape3D!) {
          case ShapeType3D.cube:
            shapePoints = _shapeDrawingService.drawCube(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType3D.cylinder:
            shapePoints = _shapeDrawingService.drawCylinder(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
            break;
          case ShapeType3D.pyramid:
            shapePoints = _shapeDrawingService.drawPyramid(_shapeStartPoint!, _shapeSize, _shapeSize);
            break;
          case ShapeType3D.sphere:
            shapePoints = _shapeDrawingService.drawSphere(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType3D.cone:
            shapePoints = _shapeDrawingService.drawCone(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
            break;
          case ShapeType3D.prism:
            shapePoints = _shapeDrawingService.drawPrism(_shapeStartPoint!, _shapeSize, _shapeSize);
            break;
        }
      } else {
        // Draw 2D shape
        switch (_selectedShape2D) {
          case ShapeType2D.circle:
            shapePoints = _shapeDrawingService.drawCircle(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.rectangle:
            shapePoints = _shapeDrawingService.drawRectangle(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
            break;
          case ShapeType2D.square:
            shapePoints = _shapeDrawingService.drawSquare(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType2D.triangle:
            shapePoints = _shapeDrawingService.drawTriangle(
              _shapeStartPoint!,
              _shapeSize,
              angle1: _triangleAngle1,
              angle2: _triangleAngle2,
              angle3: _triangleAngle3,
            );
            break;
          case ShapeType2D.line:
            final endPoint = Offset(
              _shapeStartPoint!.dx + _shapeSize,
              _shapeStartPoint!.dy,
            );
            shapePoints = _shapeDrawingService.drawLine(_shapeStartPoint!, endPoint);
            break;
          case ShapeType2D.arrow:
            final endPoint = Offset(
              _shapeStartPoint!.dx + _shapeSize,
              _shapeStartPoint!.dy,
            );
            shapePoints = _shapeDrawingService.drawArrow(_shapeStartPoint!, endPoint);
            break;
          case ShapeType2D.pentagon:
            shapePoints = _shapeDrawingService.drawPentagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.hexagon:
            shapePoints = _shapeDrawingService.drawHexagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.star:
            shapePoints = _shapeDrawingService.drawStar(_shapeStartPoint!, _shapeSize / 2);
            break;
        }
      }

      if (shapePoints.isNotEmpty) {
        final stroke = DrawingStroke(
          points: shapePoints,
          color: _currentColor,
          width: _lineWidth,
          opacity: _opacity,
          isEraser: false,
        );
        _strokes.add(stroke);
        _saveState();
      }

      _shapeStartPoint = null;
      notifyListeners();
      return;
    }

    if (_currentStroke.isNotEmpty) {
      DrawingStroke stroke;

      // Try shape recognition if auto-shape is enabled
      if (_autoShapeEnabled && _mode == DrawingMode.pen) {
        final recognizedShape = _shapeService.recognizeShape(_currentStroke);
        
        if (recognizedShape != null) {
          // Convert recognized shape to stroke
          stroke = DrawingStroke(
            points: recognizedShape.points.map((offset) => 
              DrawingPoint(offset: offset, pressure: 0.5)
            ).toList(),
            color: _currentColor,
            width: _lineWidth,
            opacity: _opacity,
            isEraser: false,
          );
        } else {
          // Use original stroke
          stroke = DrawingStroke(
            points: List.from(_currentStroke),
            color: _currentColor,
            width: _lineWidth,
            opacity: _opacity,
            isEraser: _mode == DrawingMode.eraser,
          );
        }
      } else {
        stroke = DrawingStroke(
          points: List.from(_currentStroke),
          color: _currentColor,
          width: _lineWidth,
          opacity: _opacity,
          isEraser: _mode == DrawingMode.eraser,
        );
      }

      _strokes.add(stroke);
      _saveState();
      _currentStroke.clear();
    }
    notifyListeners();
  }

  List<DrawingPoint> get currentStroke => _currentStroke;

  // Get preview shape for current shape mode
  List<DrawingPoint> getShapePreview() {
    if (_mode != DrawingMode.shape || _shapeStartPoint == null) {
      return [];
    }

    if (_selectedShape3D != null) {
      switch (_selectedShape3D!) {
        case ShapeType3D.cube:
          return _shapeDrawingService.drawCube(_shapeStartPoint!, _shapeSize);
        case ShapeType3D.cylinder:
          return _shapeDrawingService.drawCylinder(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
        case ShapeType3D.pyramid:
          return _shapeDrawingService.drawPyramid(_shapeStartPoint!, _shapeSize, _shapeSize);
        case ShapeType3D.sphere:
          return _shapeDrawingService.drawSphere(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType3D.cone:
          return _shapeDrawingService.drawCone(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
        case ShapeType3D.prism:
          return _shapeDrawingService.drawPrism(_shapeStartPoint!, _shapeSize, _shapeSize);
      }
    } else {
      switch (_selectedShape2D) {
        case ShapeType2D.circle:
          return _shapeDrawingService.drawCircle(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.rectangle:
          return _shapeDrawingService.drawRectangle(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
        case ShapeType2D.square:
          return _shapeDrawingService.drawSquare(_shapeStartPoint!, _shapeSize);
        case ShapeType2D.triangle:
          return _shapeDrawingService.drawTriangle(
            _shapeStartPoint!,
            _shapeSize,
            angle1: _triangleAngle1,
            angle2: _triangleAngle2,
            angle3: _triangleAngle3,
          );
        case ShapeType2D.line:
          final endPoint = Offset(
            _shapeStartPoint!.dx + _shapeSize,
            _shapeStartPoint!.dy,
          );
          return _shapeDrawingService.drawLine(_shapeStartPoint!, endPoint);
        case ShapeType2D.arrow:
          final endPoint = Offset(
            _shapeStartPoint!.dx + _shapeSize,
            _shapeStartPoint!.dy,
          );
          return _shapeDrawingService.drawArrow(_shapeStartPoint!, endPoint);
        case ShapeType2D.pentagon:
          return _shapeDrawingService.drawPentagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.hexagon:
          return _shapeDrawingService.drawHexagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.star:
          return _shapeDrawingService.drawStar(_shapeStartPoint!, _shapeSize / 2);
      }
    }
    return [];
  }

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

  // Convert selected strokes to shapes
  void convertSelectionToShapes() {
    if (_selectionRect == null) return;

    // Find strokes within selection
    final selectedIndices = <int>[];
    for (int i = 0; i < _strokes.length; i++) {
      final stroke = _strokes[i];
      if (_isStrokeInSelection(stroke, _selectionRect!)) {
        selectedIndices.add(i);
      }
    }

    // Try to recognize and replace each stroke
    for (final index in selectedIndices.reversed) {
      final stroke = _strokes[index];
      final recognizedShape = _shapeService.recognizeShape(stroke.points);
      
      if (recognizedShape != null) {
        // Replace with perfect shape
        _strokes[index] = DrawingStroke(
          points: recognizedShape.points.map((offset) => 
            DrawingPoint(offset: offset, pressure: 0.5)
          ).toList(),
          color: stroke.color,
          width: stroke.width,
          opacity: stroke.opacity,
          isEraser: stroke.isEraser,
        );
      }
    }

    if (selectedIndices.isNotEmpty) {
      _saveState();
      clearSelection();
      notifyListeners();
    }
  }

  bool _isStrokeInSelection(DrawingStroke stroke, Rect selection) {
    // Check if any point of the stroke is within selection
    for (final point in stroke.points) {
      if (selection.contains(point.offset)) {
        return true;
      }
    }
    return false;
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
      
      ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
      
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

  // Text input methods
  void startTextInput(Offset position) {
    _textInputPosition = position;
    notifyListeners();
  }

  void addTextObject(String text, {TextType type = TextType.normal}) {
    if (_textInputPosition == null || text.trim().isEmpty) return;

    final textObj = TextObject(
      text: text,
      position: _textInputPosition!,
      color: _currentColor,
      type: type,
    );

    _textObjects.add(textObj);
    _textInputPosition = null;
    notifyListeners();
  }

  void selectTextObject(TextObject? textObj) {
    _selectedTextObject = textObj;
    notifyListeners();
  }

  void updateTextObject(String id, String newText) {
    final index = _textObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _textObjects[index] = _textObjects[index].copyWith(text: newText);
      notifyListeners();
    }
  }

  void deleteTextObject(String id) {
    _textObjects.removeWhere((obj) => obj.id == id);
    if (_selectedTextObject?.id == id) {
      _selectedTextObject = null;
    }
    notifyListeners();
  }

  void moveTextObject(String id, Offset newPosition) {
    final index = _textObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _textObjects[index] = _textObjects[index].copyWith(position: newPosition);
      notifyListeners();
    }
  }

  void cancelTextInput() {
    _textInputPosition = null;
    notifyListeners();
  }

  // Settings methods
  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _isDarkMode = newSettings.isDarkMode;
    _autoShapeEnabled = newSettings.autoShapeEnabled;
    notifyListeners();
  }

  void togglePalmRejection() {
    _settings = _settings.copyWith(palmRejection: !_settings.palmRejection);
    notifyListeners();
  }

  void toggleGridLines() {
    _settings = _settings.copyWith(showGridLines: !_settings.showGridLines);
    notifyListeners();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
