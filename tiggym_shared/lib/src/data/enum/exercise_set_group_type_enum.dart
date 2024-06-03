enum ExerciseSetGroupTypeEnum {
  unique,
  multiple;
  static ExerciseSetGroupTypeEnum fromName(String name) => ExerciseSetGroupTypeEnum.values.firstWhere((element) => element.name == name);
}