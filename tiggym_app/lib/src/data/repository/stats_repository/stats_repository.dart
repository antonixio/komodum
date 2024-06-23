import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/models/stats_model.dart';
import 'package:tiggym/src/data/repository/training_session_repository/training_session_repository.dart';

class StatsRepository {
  final repo = GetIt.I.get<TrainingSessionRepository>();
  Future<StatsModel> getData() async {
    final trainings = await repo.getTrainings();
    return StatsModel.dummy().copyWith(baseSessions: trainings);
  }
}
