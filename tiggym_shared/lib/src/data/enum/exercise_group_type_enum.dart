enum ExerciseGroupTypeEnum {
  unique,
  compound;

  static ExerciseGroupTypeEnum fromName(String name) => ExerciseGroupTypeEnum.values.firstWhere((element) => element.name == name);
}
