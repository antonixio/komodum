import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class TrainingTemplateRepository {
  final _trainings = BehaviorSubject<List<TrainingTemplateModel>>.seeded([]);
  ValueStream<List<TrainingTemplateModel>> get trainings => _trainings;

  void updateTrainings(SyncModel<SyncTrainingTemplatesModel> trainingsSync) {
    _trainings.add(trainingsSync.data.trainings);
  }
}
