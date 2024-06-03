import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/repository/crud_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

extension ExerciseSetMetaTrainingSessionModelExtensions on ExerciseSetMetaTrainingSessionModel {
  DefaultCrudRepository<ExerciseSetMetaTrainingSessionModel> getDefaultCrudRepository() {
    switch (runtimeType) {
      case ExerciseSetMetaRepsTrainingSessionModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaRepsTrainingSessionModel>>();
      case ExerciseSetMetaRepsAndWeightTrainingSessionModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaRepsAndWeightTrainingSessionModel>>();
      case ExerciseSetMetaTimeTrainingSessionModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaTimeTrainingSessionModel>>();
      case ExerciseSetMetaTimeAndDistanceTrainingSessionModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaTimeAndDistanceTrainingSessionModel>>();
      case ExerciseSetMetaDistanceTrainingSessionModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaDistanceTrainingSessionModel>>();
      default:
        throw Exception("Not found");
    }
  }
}
