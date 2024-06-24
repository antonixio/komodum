import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/models/stats_model.dart';
import 'package:tiggym/src/data/repository/exercise_repository/exercise_repository.dart';
import 'package:tiggym/src/data/repository/training_session_repository/training_session_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class StatsRepository {
  final repo = GetIt.I.get<TrainingSessionRepository>();

  Future<StatsModel> getData() async {
    final trainings = await repo.getTrainings();
    return StatsModel.dummy().copyWith(baseSessions: trainings);
  }

  Future<StatsModel> getDataA() async {
    // final trainings = await repo.getTrainings();
    final trainings = List.generate(
      700,
      (index) => TrainingSessionModel(
        name: "Workout",
        exercises: List.generate(Random().nextInt(4) + 4, (index) {
          final group = ExerciseGroupTrainingSessionModel.compoundFromExercise(exercise: GetIt.I.get<ExerciseRepository>().data.value.randomItem()!);
          return group.copyWith(
              exercises: group.exercises
                  .map((e) => e.copyWith(
                      groupSets: e.groupSets
                          .map((e) => e.copyWith(
                              sets: e.sets
                                  .map((e) => e.copyWith(
                                        done: true,
                                        meta: e.meta is ExerciseSetMetaRepsAndWeightTrainingSessionModel
                                            ? (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel).copyWith(reps: Random().nextInt(8) + 10, weight: Random().nextDouble() * 64)
                                            : e.meta,
                                      ))
                                  .toList()))
                          .toList()))
                  .toList());
        }),
        date: DateTime.now().add(Duration(days: -index)),
        duration: Duration(minutes: Random().nextInt(45) + 60),
      ),
    ).where((element) => Random().nextInt(10) > 3).toList();
    return StatsModel.dummy().copyWith(baseSessions: trainings);
  }
}
