// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shunnck/screens/home.dart';
import 'generated/l10n.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {}

  String _getTitle(BuildContext context) {
    return 'Mi aplicación';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'inicio',
      routes: {
        'inicio': (context) => const HomeScreen(),
      },
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        primaryColor: const Color(0xFFFF2D55),
        colorScheme: const ColorScheme.light(
          background: Color(0xFFE1E1E1),
          onBackground: Color(0xFF171717),
          secondary: Color(0xFF424242),
          onSecondary: Color(0xFF171717),
          tertiary: Color(0xFFFFFFFF),
        ),
        fontFamily: 'PON',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: const Color(0xFFFF2D55),
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF171717),
          onBackground: Color(0xFFF8F8F8),
          secondary: Color(0xFFCACACA),
          onSecondary: Color(0xFFF8F8F8),
          tertiary: Color(0xFF282828),
        ),
        fontFamily: 'PON',
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('eo', ''),
        Locale('tl', ''),
      ],
      onGenerateTitle: (BuildContext context) => _getTitle(context),
    );
  }
}
