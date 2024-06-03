import 'package:tiggym_shared/src/data/all.dart';
import 'package:tiggym_shared/src/data/model/mappable_json_model.dart';

class SyncTrainingTemplatesResumeModel extends MappableModel {
  final List<TrainingTemplateResumeModel> trainings;

  SyncTrainingTemplatesResumeModel({
    required this.trainings,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'trainings': trainings.map((e) => e.toMap()),
    };
  }
}
