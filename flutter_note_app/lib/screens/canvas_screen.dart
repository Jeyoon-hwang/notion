import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/header.dart';
import '../widgets/floating_toolbar.dart';
import '../widgets/slider_panel.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _showGestureHint = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showGestureHint = true);
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showGestureHint = false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: provider.isDarkMode
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  DrawingCanvas(repaintBoundaryKey: _repaintBoundaryKey),
                  AppHeader(repaintBoundaryKey: _repaintBoundaryKey),
                  const FloatingToolbar(),
                  const SliderPanel(),
                  if (_showGestureHint) _buildGestureHint(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureHint() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '👆 두 손가락 탭: 실행 취소 | 세 손가락 탭: 다시 실행',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
