import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Custom font loader service
/// Allows users to upload and use their own handwriting fonts (.ttf, .otf)
/// Essential for "Gongstagram" aesthetics - students want their typed text to look handwritten
class CustomFontLoader {
  static final CustomFontLoader _instance = CustomFontLoader._internal();
  factory CustomFontLoader() => _instance;
  CustomFontLoader._internal();

  final List<CustomFont> _loadedFonts = [];
  Directory? _fontsDirectory;

  /// Get all loaded custom fonts
  List<CustomFont> get loadedFonts => List.unmodifiable(_loadedFonts);

  /// Initialize font loader
  Future<void> initialize() async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _fontsDirectory = Directory('${appDir.path}/custom_fonts');

      // Create fonts directory if it doesn't exist
      if (!await _fontsDirectory!.exists()) {
        await _fontsDirectory!.create(recursive: true);
      }

      // Load existing fonts
      await _loadExistingFonts();

      print('✅ Custom font loader initialized');
      print('   Fonts directory: ${_fontsDirectory!.path}');
      print('   Loaded ${_loadedFonts.length} custom fonts');
    } catch (e) {
      print('❌ Error initializing custom font loader: $e');
    }
  }

  /// Load existing fonts from directory
  Future<void> _loadExistingFonts() async {
    if (_fontsDirectory == null) return;

    try {
      final files = await _fontsDirectory!.list().toList();

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final extension = fileName.split('.').last.toLowerCase();

          if (extension == 'ttf' || extension == 'otf') {
            await _loadFont(file);
          }
        }
      }
    } catch (e) {
      print('❌ Error loading existing fonts: $e');
    }
  }

  /// Load a font file
  Future<CustomFont?> _loadFont(File fontFile) async {
    try {
      final fileName = fontFile.path.split('/').last;
      final fontName = fileName.split('.').first;

      // Read font file as bytes
      final fontData = await fontFile.readAsBytes();

      // Load font into Flutter
      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(Future.value(ByteData.sublistView(fontData)));
      await fontLoader.load();

      final customFont = CustomFont(
        name: fontName,
        displayName: _formatDisplayName(fontName),
        filePath: fontFile.path,
        family: fontName,
      );

      _loadedFonts.add(customFont);
      print('✅ Loaded font: $fontName');

      return customFont;
    } catch (e) {
      print('❌ Error loading font ${fontFile.path}: $e');
      return null;
    }
  }

  /// Upload and install a new font
  Future<CustomFont?> uploadFont(String sourcePath) async {
    if (_fontsDirectory == null) {
      print('❌ Font loader not initialized');
      return null;
    }

    try {
      final sourceFile = File(sourcePath);

      // Validate file exists
      if (!await sourceFile.exists()) {
        print('❌ Font file does not exist: $sourcePath');
        return null;
      }

      // Validate file extension
      final fileName = sourcePath.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      if (extension != 'ttf' && extension != 'otf') {
        print('❌ Invalid font file format. Only .ttf and .otf are supported.');
        return null;
      }

      // Copy to fonts directory
      final targetPath = '${_fontsDirectory!.path}/$fileName';
      final targetFile = await sourceFile.copy(targetPath);

      // Load the font
      final customFont = await _loadFont(targetFile);

      if (customFont != null) {
        print('✅ Font uploaded and loaded successfully: ${customFont.displayName}');
      }

      return customFont;
    } catch (e) {
      print('❌ Error uploading font: $e');
      return null;
    }
  }

  /// Delete a custom font
  Future<bool> deleteFont(String fontName) async {
    try {
      final font = _loadedFonts.firstWhere(
        (f) => f.name == fontName,
        orElse: () => throw Exception('Font not found'),
      );

      // Delete file
      final file = File(font.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from list
      _loadedFonts.removeWhere((f) => f.name == fontName);

      print('✅ Font deleted: $fontName');
      return true;
    } catch (e) {
      print('❌ Error deleting font: $e');
      return false;
    }
  }

  /// Get font by name
  CustomFont? getFontByName(String name) {
    try {
      return _loadedFonts.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Format display name (remove underscores, capitalize)
  String _formatDisplayName(String fileName) {
    return fileName
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  /// Get example fonts list (for UI)
  List<Map<String, String>> getExampleFonts() {
    return [
      {'name': '3B연필체', 'description': '손글씨 느낌의 부드러운 폰트'},
      {'name': 'Aa 폰트', 'description': '깔끔한 한글 필기체'},
      {'name': '나눔손글씨 펜', 'description': '펜으로 쓴 듯한 자연스러운 글씨'},
      {'name': '배달의민족 주아', 'description': '귀여운 손글씨 스타일'},
    ];
  }
}

/// Represents a custom font
class CustomFont {
  final String name; // Internal name (from file name)
  final String displayName; // User-friendly name
  final String filePath; // Path to font file
  final String family; // Font family name for TextStyle

  CustomFont({
    required this.name,
    required this.displayName,
    required this.filePath,
    required this.family,
  });

  @override
  String toString() => 'CustomFont($displayName)';
}
