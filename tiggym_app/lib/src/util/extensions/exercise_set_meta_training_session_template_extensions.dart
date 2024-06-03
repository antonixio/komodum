import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/repository/crud_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

extension ExerciseSetMetaTrainingTemplateModelExtensions on ExerciseSetMetaTrainingTemplateModel {
  DefaultCrudRepository<ExerciseSetMetaTrainingTemplateModel> getDefaultCrudRepository() {
    switch (runtimeType) {
      case ExerciseSetMetaRepsTrainingTemplateModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaRepsTrainingTemplateModel>>();
      case ExerciseSetMetaRepsAndWeightTrainingTemplateModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaRepsAndWeightTrainingTemplateModel>>();
      case ExerciseSetMetaTimeTrainingTemplateModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaTimeTrainingTemplateModel>>();
      case ExerciseSetMetaTimeAndDistanceTrainingTemplateModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaTimeAndDistanceTrainingTemplateModel>>();
      case ExerciseSetMetaDistanceTrainingTemplateModel:
        return GetIt.I.get<DefaultCrudRepository<ExerciseSetMetaDistanceTrainingTemplateModel>>();
      default:
        throw Exception("Not found");
    }
  }
}
