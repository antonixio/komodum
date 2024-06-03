import 'package:tiggym_shared/src/data/all.dart';
import 'package:tiggym_shared/src/data/enum/training_session_state_enum.dart';

import '../training_session_state_model.dart';

class SyncTrainingSessionModel extends MappableModel {
  final TrainingSessionModel? session;
  final TrainingSessionStateModel sessionState;

  SyncTrainingSessionModel({
    required this.session,
    required this.sessionState,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'session': session?.toMap(),
      'sessionState': sessionState.toMap(),
    };
  }

  factory SyncTrainingSessionModel.fromMap(Map<String, dynamic> map) {
    return SyncTrainingSessionModel(
      session: map['session'] != null ? TrainingSessionModel.fromMap(map['session']) : null,
      sessionState: map['sessionState'] != null
          ? TrainingSessionStateModel.fromMap(map['sessionState'])
          : TrainingSessionStateModel(
              syncId: '',
              state: TrainingSessionStateEnum.ongoing,
            ),
    );
  }
}
