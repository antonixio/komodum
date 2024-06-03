import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/repositories/exercise_repository.dart';
import 'package:tiggym_wear/src/data/repositories/training_template_repository.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';
import 'package:tiggym_wear/src/util/services/wear_connectivity_service.dart';

import '../../data/repositories/training_session_repository.dart';

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({super.key});

  @override
  State<InitializeScreen> createState() => _InitializeScreenState();
}

class _InitializeScreenState extends State<InitializeScreen> {
  @override
  void initState() {
    initAndGo();
    super.initState();
  }

  Future<void> initAndGo() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final languageCode = Localizations.localeOf(context).languageCode;
      await LocalizationService.initialize(languageCode);
      await SharedPrefsService.instance.initialize();
      GetIt.I.registerSingleton(TrainingSessionRepository());
      GetIt.I.registerSingleton(TrainingTemplateRepository());
      GetIt.I.registerSingleton(ExerciseRepository());
      await WearConnectivityService.instance.initialize();

      if (WearConnectivityService.instance.connectedDevice.value != null) {
        context.pushReplacementNamed('/home');
      } else {
        context.pushReplacementNamed('/find');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CSafeViewContainerWidget(
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}
