import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import 'src/ui/screens/exercises/exercises_screen.dart';
import 'src/ui/screens/home/home_screen.dart';
import 'src/ui/screens/initialize/initialize_screen.dart';
import 'src/ui/screens/tags/tags_screen.dart';
import 'src/ui/screens/training_session/training_sessions_screen.dart';
import 'src/ui/screens/training_template/training_templates_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    localization.onTranslatedLanguage = (_) {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Brightness brightness = MediaQuery.of(context).platformBrightness;
    Brightness brightness = Brightness.dark;
    ThemeData theme = ThemeData(
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(
        // seedColor: Colors.blue,
        seedColor: const Color(0xFF90d9a1),
        surfaceVariant: brightness == Brightness.light ? Colors.grey.shade300 : const Color.fromARGB(255, 46, 46, 46),
        surface: brightness == Brightness.light ? Colors.white : const Color(0xFF1D1D1D),
        surfaceTint: brightness == Brightness.light ? Colors.white : const Color(0xFF000000),
        background: brightness == Brightness.light ? Colors.grey.shade100 : const Color(0xFF151515),
        brightness: brightness,
        outline: (brightness == Brightness.light ? const Color(0xFF010101) : Colors.grey.shade100).withOpacity(0.1),
      ),
      useMaterial3: true,
    );
    return GlobalLoaderOverlay(
      overlayColor: theme.colorScheme.background.withOpacity(0.5),
      useDefaultLoading: false,
      overlayWidgetBuilder: (progress) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      child: MaterialApp(
        theme: theme,
        initialRoute: '/',
        supportedLocales: AppLocale.map.entries.map((e) => e.key),
        localizationsDelegates: localization.localizationsDelegates.isNotEmpty
            ? localization.localizationsDelegates
            : [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
        title: 'TigGym',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => const InitializeScreen(),
          '/home': (_) => const HomeScreen(),
          '/tags': (_) => const TagsScreen(),
          '/exercises': (_) => const ExercisesScreen(),
          '/workouts': (_) => const TrainingTemplatesScreen(),
          '/sessions': (_) => const TrainingSessionsScreen(),
        },
      ),
    );
  }
}
