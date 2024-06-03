import 'package:tiggym_shared/tiggym_shared.dart';

class CurrentSessionsModel {
  final TrainingSessionModel? phoneSession;
  final TrainingSessionModel? watchSession;
  final TrainingSessionStateModel? sessionState;

  CurrentSessionsModel({
    required this.phoneSession,
    required this.watchSession,
    required this.sessionState,
  });
}
