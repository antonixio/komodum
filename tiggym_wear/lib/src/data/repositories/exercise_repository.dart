import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class ExerciseRepository {
  final _exercises = BehaviorSubject<List<ExerciseModel>>.seeded([]);
  ValueStream<List<ExerciseModel>> get exercises => _exercises;

  void updateExercises(SyncModel<SyncExercisesModel> exercisesSync) {
    _exercises.add(exercisesSync.data.exercises);
  }
}
