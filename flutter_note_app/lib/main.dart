import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/drawing_provider.dart';
import 'providers/theme_provider.dart';
import 'models/planner.dart';
import 'models/practice_session.dart';
import 'screens/main_navigation_screen.dart';
import 'services/custom_font_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize custom font loader
  await CustomFontLoader().initialize();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for immersive experience (can be toggled in settings)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Drawing provider for canvas
        ChangeNotifierProvider(create: (_) => DrawingProvider()),

        // Theme provider for Gongstagram aesthetics
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Planner manager for tasks and study time tracking
        ChangeNotifierProvider(create: (_) => PlannerManager()),

        // Practice session manager for N회독 system
        ChangeNotifierProvider(create: (_) => PracticeSessionManager()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: '공스타그램 - 학습 플래너',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
