import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/screens/find_device_screen/find_device_screen.dart';
import 'package:tiggym_wear/src/ui/screens/initialize_screen.dart';

import 'src/ui/screens/home/home_screen.dart';
import 'src/ui/widgets/c_toast_container/c_toast_container_widget.dart';
import 'src/ui/widgets/c_toast_container/c_toast_controller.dart';

void main() {
  GetIt.I.registerSingleton(CToastController());

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    LocalizationService.localizationInstance.onTranslatedLanguage = (_) {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Brightness brightness = MediaQuery.of(context).platformBrightness;
    Brightness brightness = Brightness.dark;
    ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        // seedColor: Colors.blue,
        seedColor: const Color(0xFF90d9a1),
        surfaceVariant: brightness == Brightness.light ? Colors.grey.shade300 : const Color.fromARGB(255, 46, 46, 46),
        surface: brightness == Brightness.light ? Colors.white : const Color(0xFF1D1D1D),
        surfaceTint: brightness == Brightness.light ? Colors.white : const Color(0xFF000000),
        // background: brightness == Brightness.light ? Colors.grey.shade100 : const Color(0xFF151515),
        background: brightness == Brightness.light ? Colors.grey.shade100 : Colors.black,
        brightness: brightness,
        outline: (brightness == Brightness.light ? const Color(0xFF010101) : Colors.grey.shade100).withOpacity(0.1),
      ),
      useMaterial3: true,
    );
    return CToastContainerWidget(
      child: MaterialApp(
        theme: theme,
        supportedLocales: AppLocale.map.entries.map((e) => e.key),
        localizationsDelegates: LocalizationService.localizationInstance.localizationsDelegates.isNotEmpty
            ? LocalizationService.localizationInstance.localizationsDelegates
            : [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
        routes: {
          '/': (_) => const InitializeScreen(),
          '/find': (_) => const FindDeviceScreen(),
          '/home': (_) => const HomeScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> teste() async {
    final connectivity = FlutterWearOsConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
