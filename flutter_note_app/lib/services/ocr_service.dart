import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> recognizeText(ui.Image image) async {
    try {
      // Convert ui.Image to InputImage
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return '';

      final Uint8List bytes = byteData.buffer.asUint8List();
      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.width * 4,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print('Error recognizing text: $e');
      return '';
    }
  }

  bool isMathFormula(String text) {
    // Check if text contains mathematical symbols
    final mathPatterns = [
      r'\+', r'-', r'\*', r'/', r'=', r'\^', 
      r'√', r'∫', r'∑', r'π', r'α', r'β', r'θ',
      r'\d+\s*[+\-*/=]\s*\d+', // Basic arithmetic
      r'x\s*[+\-*/=]', // Variables
      r'\([^)]+\)', // Parentheses
    ];

    for (var pattern in mathPatterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  String convertToLaTeX(String text) {
    // Basic conversion to LaTeX format
    String latex = text;

    // Replace common symbols
    latex = latex.replaceAll('×', r'\times');
    latex = latex.replaceAll('÷', r'\div');
    latex = latex.replaceAll('≠', r'\neq');
    latex = latex.replaceAll('≤', r'\leq');
    latex = latex.replaceAll('≥', r'\geq');
    latex = latex.replaceAll('∞', r'\infty');
    latex = latex.replaceAll('π', r'\pi');
    latex = latex.replaceAll('√', r'\sqrt');
    latex = latex.replaceAll('∫', r'\int');
    latex = latex.replaceAll('∑', r'\sum');
    
    // Handle fractions (simple pattern)
    latex = latex.replaceAllMapped(
      RegExp(r'(\d+)\s*/\s*(\d+)'),
      (match) => r'\frac{' + match.group(1)! + '}{' + match.group(2)! + '}',
    );

    // Handle exponents (simple pattern)
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)\^(\d+)'),
      (match) => match.group(1)! + '^{' + match.group(2)! + '}',
    );

    // Handle square root (simple pattern)
    latex = latex.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
      (match) => r'\sqrt{' + match.group(1)! + '}',
    );

    return latex;
  }

  Future<Map<String, dynamic>> processHandwriting(ui.Image image) async {
    final text = await recognizeText(image);
    final isMath = isMathFormula(text);
    final latex = isMath ? convertToLaTeX(text) : '';

    return {
      'text': text,
      'isMath': isMath,
      'latex': latex,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
