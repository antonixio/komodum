import 'package:tiggym_shared/src/data/all.dart';

class SyncTrainingTemplatesModel extends MappableModel {
  final List<TrainingTemplateModel> trainings;

  SyncTrainingTemplatesModel({
    required this.trainings,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'trainings': trainings.map((e) => e.toMap()).toList(),
    };
  }

  factory SyncTrainingTemplatesModel.fromMap(Map<String, dynamic> map) {
    return SyncTrainingTemplatesModel(trainings: (map['trainings'] as List<dynamic>).map((e) => TrainingTemplateModel.fromMap(e)).toList());
  }
}
