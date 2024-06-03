import 'package:tiggym_shared/src/data/all.dart';

class SyncExercisesModel extends MappableModel {
  final List<ExerciseModel> exercises;

  SyncExercisesModel({
    required this.exercises,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory SyncExercisesModel.fromMap(Map<String, dynamic> map) {
    return SyncExercisesModel(exercises: (map['exercises'] as List<dynamic>).map((e) => ExerciseModel.fromMap(e)).toList());
  }
}
