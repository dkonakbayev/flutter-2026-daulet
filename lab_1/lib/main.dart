import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _seed = Color(0xFF2E7D6B);

  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer Shifts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => ShellScreen(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
        ),
      },
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
