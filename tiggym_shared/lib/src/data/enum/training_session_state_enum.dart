enum TrainingSessionStateEnum {
  ongoing,
  finished,
  discarded;

  static TrainingSessionStateEnum fromName(String name) => TrainingSessionStateEnum.values.firstWhere((element) => element.name == name);
}
