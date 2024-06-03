import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class TrainingTemplateController {
  final trainingTemplates = BehaviorSubject<SyncModel<SyncTrainingTemplatesResumeModel>>.seeded(
    SyncModel(
      id: '',
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingTemplatesResumeModel(
        trainings: [],
      ),
    ),
  );
}
