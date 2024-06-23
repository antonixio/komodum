import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tiggym/src/data/repository/stats_repository/stats_repository.dart';
import 'package:tiggym/src/util/services/purchase_service.dart';
import 'package:tiggym/src/util/services/wear_connectivity_service.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/crud_repository.dart';
import '../../../data/repository/exercise_repository/exercise_repository.dart';
import '../../../data/repository/home_repository/home_repository.dart';
import '../../../data/repository/initializable_repository.dart';
import '../../../data/repository/tag_repository/tag_repository.dart';
import '../../../data/repository/training_session_repository/training_session_repository.dart';
import '../../../data/repository/training_session_repository/training_session_resume_repository.dart';
import '../../../data/repository/training_template_repository/training_template_repository.dart';
import '../../../data/repository/training_template_repository/training_template_resume_repository.dart';
import '../../../util/database/database_helper.dart';

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({super.key});

  @override
  State<InitializeScreen> createState() => _InitializeScreenState();
}

class _InitializeScreenState extends State<InitializeScreen> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final languageCode = Localizations.localeOf(context).languageCode;

      await _tryInit(() async => SharedPrefsService.instance.initialize());
      await _tryInit(() async {
        await localization.init(
          mapLocales: AppLocale.map.entries.map((e) => MapLocale(e.key.languageCode, e.value.texts)).toList(),
          initLanguageCode: languageCode,
        );
      });

      await _tryInit(() async {
        await DatabaseHelper.instance.initialize();
      });
      await _tryInit(() async => PurchaseService.instance.initialize());
      await _setupDependencies();
      await _tryInit(() async => WearConnectivityService.instance.initialize());
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/home');
    });
    super.initState();
  }

  Future<void> _setupDependencies() async {
    await _registerSingletonRepository<TagRepository>(TagRepository());
    await _registerSingletonRepository<ExerciseRepository>(ExerciseRepository());
    await _registerSingletonRepository<TrainingTemplateResumeRepository>(TrainingTemplateResumeRepository());
    await _registerSingletonRepository<HomeRepository>(HomeRepository());
    GetIt.I.registerFactory<TrainingTemplateRepository>(() => TrainingTemplateRepository());
    GetIt.I.registerFactory<TrainingSessionRepository>(() => TrainingSessionRepository());
    GetIt.I.registerFactory<TrainingSessionResumeRepository>(() => TrainingSessionResumeRepository());
    GetIt.I.registerSingleton<TrainingSessionController>(TrainingSessionController()..initialize());
    _setupDefaultCrudRepositorySession();
    _setupDefaultCrudRepositoryTemplate();
    GetIt.I.registerFactory<StatsRepository>(() => StatsRepository());
  }

  void _setupDefaultCrudRepositorySession() {
    GetIt.I.registerFactory(() => DefaultCrudRepository<TrainingSessionNoteModel>(table: 'training_session_note', fromMap: TrainingSessionNoteModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<TrainingSessionModel>(table: 'training_session', fromMap: TrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseGroupTrainingSessionModel>(table: 'exercise_group_training_session', fromMap: ExerciseGroupTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseTrainingSessionModel>(table: 'exercise_training_session', fromMap: ExerciseTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetGroupTrainingSessionModel>(table: 'exercise_set_group_training_session', fromMap: ExerciseSetGroupTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetTrainingSessionModel>(table: 'exercise_set_training_session', fromMap: ExerciseSetTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(
        () => DefaultCrudRepository<ExerciseSetMetaRepsTrainingSessionModel>(table: 'exercise_set_meta_reps_training_session', fromMap: ExerciseSetMetaRepsTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetMetaRepsAndWeightTrainingSessionModel>(
        table: 'exercise_set_meta_reps_and_weight_training_session', fromMap: ExerciseSetMetaRepsAndWeightTrainingSessionModel.fromMap));
    GetIt.I
        .registerFactory(() => DefaultCrudRepository<ExerciseSetMetaTimeTrainingSessionModel>(table: 'exercise_set_time_training_session', fromMap: ExerciseSetMetaTimeTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(
        () => DefaultCrudRepository<ExerciseSetMetaDistanceTrainingSessionModel>(table: 'exercise_set_distance_training_session', fromMap: ExerciseSetMetaDistanceTrainingSessionModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetMetaTimeAndDistanceTrainingSessionModel>(
        table: 'exercise_set_time_and_distance_training_session', fromMap: ExerciseSetMetaTimeAndDistanceTrainingSessionModel.fromMap));
  }

  void _setupDefaultCrudRepositoryTemplate() {
    GetIt.I.registerFactory(() => DefaultCrudRepository<TrainingTemplateModel>(table: 'training_template', fromMap: TrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseGroupTrainingTemplateModel>(table: 'exercise_group_training_template', fromMap: ExerciseGroupTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseTrainingTemplateModel>(table: 'exercise_training_template', fromMap: ExerciseTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetGroupTrainingTemplateModel>(table: 'exercise_set_group_training_template', fromMap: ExerciseSetGroupTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetTrainingTemplateModel>(table: 'exercise_set_training_template', fromMap: ExerciseSetTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(
        () => DefaultCrudRepository<ExerciseSetMetaRepsTrainingTemplateModel>(table: 'exercise_set_meta_reps_training_template', fromMap: ExerciseSetMetaRepsTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetMetaRepsAndWeightTrainingTemplateModel>(
        table: 'exercise_set_meta_reps_and_weight_training_template', fromMap: ExerciseSetMetaRepsAndWeightTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(
        () => DefaultCrudRepository<ExerciseSetMetaTimeTrainingTemplateModel>(table: 'exercise_set_time_training_template', fromMap: ExerciseSetMetaTimeTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(
        () => DefaultCrudRepository<ExerciseSetMetaDistanceTrainingTemplateModel>(table: 'exercise_set_distance_training_template', fromMap: ExerciseSetMetaDistanceTrainingTemplateModel.fromMap));
    GetIt.I.registerFactory(() => DefaultCrudRepository<ExerciseSetMetaTimeAndDistanceTrainingTemplateModel>(
        table: 'exercise_set_time_and_distance_training_template', fromMap: ExerciseSetMetaTimeAndDistanceTrainingTemplateModel.fromMap));
  }

  Future<void> _registerSingletonRepository<T extends InitializableRepository>(T repository) async {
    GetIt.I.registerSingleton<T>(repository);
    await repository.initialize();
  }

  Future<void> _tryInit(Future<void> Function() callback) async {
    try {
      await callback.call();
    } catch (err) {
      debugPrint(err.toString());
      try {
        // FirebaseCrashlytics.instance.log("Failed to initialize $err");
      } catch (_) {
        //
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
