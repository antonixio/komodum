// import 'package:tiggym_shared/tiggym_shared.dart';

import 'dart:ffi';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/repository/exercise_repository/exercise_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../ui/widgets/c_charts/c_line_chart_widget.dart';
import '../enums/stats_period_enum.dart';

class StatsModel {
  final List<TrainingSessionModel> baseSessions;
  late final List<TrainingSessionModel> sessions;
  final StatsPeriodEnum period;
  final (DateTime, DateTime) startEnd;
  final dynamic filter;
  late final Map<DateTime, int> heatmapData;
  late final int sessionsInPeriod;
  late final Duration averageSessionTime;
  late final double exercisesPerSession;
  late final double setsPerSession;
  late final Map<int, int> weeklyDistribution;
  late final List<ExerciseStatsModel> exercisesStats;
  late final List<int>? selectedExercises;
  late final List<ExerciseModel> selectedExerciseList;
  bool get canGoNext => startEnd.$2.year <= 9999;

  bool get canGoPrevious => startEnd.$1.compareTo(DateTime(1970, 1, 1)) > 0;

  String periodText(BuildContext context) {
    switch (period) {
      case StatsPeriodEnum.week:
        return "${startEnd.$1.format(AppLocale.formatDate.getTranslation(context))} - ${startEnd.$2.format(AppLocale.formatDate.getTranslation(context))}";
      case StatsPeriodEnum.month:
        return startEnd.$1.dateOnly.format(AppLocale.formatDateMonthYear.getTranslation(context));
      case StatsPeriodEnum.year:
        return startEnd.$1.dateOnly.format(AppLocale.formatDateYear.getTranslation(context));
      case StatsPeriodEnum.all:
        return "";
    }
  }

  StatsModel({
    required this.baseSessions,
    required this.period,
    required this.startEnd,
    required this.filter,
    List<int>? selectedExercises,
  }) {
    selectedExerciseList = GetIt.I.get<ExerciseRepository>().data.value.where((element) => selectedExercises != null ? selectedExercises.contains(element.id) : true).toList();
    this.selectedExercises = selectedExerciseList.map((e) => e.id).toList();

    sessions = selectedExerciseList.isNotEmpty
        ? baseSessions.where((s) => s.exercises.any((g) => g.exercises.any((e) => selectedExerciseList.any((se) => e.exercise.id == se.id)))).toList()
        : [...baseSessions];
    final sessionsMap = Map.fromEntries(
      sessions.groupBy((p0) => p0.date.dateOnly).entries.where((element) => element.value.isNotEmpty).map(
            (value) => MapEntry(value.key, period != StatsPeriodEnum.all ? 2 : 3),
          ),
    );
    if (period != StatsPeriodEnum.all) {
      final periodDates = startEnd.$1.getDaysUntil(end: startEnd.$2.compareTo(DateTime.now().dateOnly) > 0 ? DateTime.now() : startEnd.$2);
      for (var periodDate in periodDates) {
        sessionsMap.addOrUpdateEntry(MapEntry(periodDate, sessionsMap.containsKey(periodDate) ? 3 : 1));
      }
    }

    final sessionsWithinPeriod = period == StatsPeriodEnum.all ? sessions : sessions.where((element) => element.date.dateOnly.isBetween(startEnd.$1, startEnd.$2)).toList();
    sessionsInPeriod = sessionsWithinPeriod.length;
    averageSessionTime = sessionsInPeriod == 0
        ? Duration.zero
        : Duration(seconds: (sessionsWithinPeriod.fold(Duration.zero, (previousValue, element) => previousValue + element.duration).inSeconds / sessionsInPeriod).floor());
    exercisesPerSession = sessionsInPeriod == 0 ? 0 : sessionsWithinPeriod.fold(0, (p1, e1) => p1 + e1.exercises.fold(0, (p2, e2) => p2 + e2.exercises.length)) / sessionsInPeriod;
    setsPerSession = sessionsInPeriod == 0
        ? 0
        : sessionsWithinPeriod.fold(
                0, (p1, e1) => p1 + e1.exercises.fold(0, (p2, e2) => p2 + e2.exercises.fold(0, (p3, e3) => p3 + e3.groupSets.fold(0, (p4, e4) => p4 + e4.sets.where((eSet) => eSet.done).length)))) /
            sessionsInPeriod;
    weeklyDistribution = Map.fromEntries(List.generate(DateTime.daysPerWeek, (index) => MapEntry(index + 1, 0)))
        .addOrUpdate(sessionsWithinPeriod.groupBy((p0) => p0.date.weekday).map((key, value) => MapEntry(key, value.length)));
    exercisesStats = selectedExerciseList
        .map((e) => ExerciseStatsModel.fromExercise(
              exercise: e,
              period: period,
              sessions: sessionsWithinPeriod,
              startEnd: startEnd,
            ))
        .toList();
    heatmapData = sessionsMap;
  }

  StatsModel.dummy()
      : this(
          baseSessions: [],
          filter: null,
          period: StatsPeriodEnum.month,
          startEnd: (DateTime.now().copyWith(day: 1).dateOnly, DateTime.now().lastDayOfMonth.dateOnly),
          selectedExercises: null,
        );

  StatsModel previousPeriod() {
    switch (period) {
      case StatsPeriodEnum.week:
        return copyWith(startEnd: (
          startEnd.$1.dateOnly.add(const Duration(days: -7)),
          startEnd.$1.dateOnly.add(const Duration(days: -7)).lastDayOfWeek,
        ));
      case StatsPeriodEnum.month:
        return copyWith(startEnd: (startEnd.$1.dateOnly.addMonths(-1), startEnd.$1.dateOnly.addMonths(-1).lastDayOfMonth));
      case StatsPeriodEnum.year:
        return copyWith(startEnd: (startEnd.$1.dateOnly.addMonths(-12), startEnd.$1.dateOnly.addMonths(-12).lastDayOfMonth));
      default:
        throw Exception("");
    }
  }

  StatsModel nextPeriod() {
    switch (period) {
      case StatsPeriodEnum.week:
        return copyWith(startEnd: (
          startEnd.$1.dateOnly.add(const Duration(days: 7)),
          startEnd.$1.dateOnly.add(const Duration(days: 7)).lastDayOfWeek,
        ));
      case StatsPeriodEnum.month:
        return copyWith(startEnd: (startEnd.$1.dateOnly.addMonths(1), startEnd.$1.dateOnly.addMonths(1).lastDayOfMonth));
      case StatsPeriodEnum.year:
        return copyWith(startEnd: (startEnd.$1.dateOnly.addMonths(12), startEnd.$1.dateOnly.addMonths(12).lastDayOfMonth));
      default:
        throw Exception("");
    }
  }

  StatsModel changePeriod({
    required StatsPeriodEnum period,
  }) {
    final today = DateTime.now();
    final startEnd = switch (period) {
      StatsPeriodEnum.week => (today.mostRecentSunday, today.mostRecentSunday.lastDayOfWeek.dateOnly),
      StatsPeriodEnum.month => (today.copyWith(day: 1).dateOnly, today.lastDayOfMonth.dateOnly),
      StatsPeriodEnum.year => (today.copyWith(month: 1, day: 1).dateOnly, today.copyWith(month: 12).lastDayOfMonth.dateOnly),
      StatsPeriodEnum.all => (DateTime.fromMillisecondsSinceEpoch(0), DateTime(9999, 12).lastDayOfMonth.dateOnly)
    };
    return copyWith(period: period, startEnd: startEnd);
  }

  StatsModel copyWith({
    StatsPeriodEnum? period,
    (DateTime, DateTime)? startEnd,
    dynamic filter,
    List<TrainingSessionModel>? baseSessions,
    ValueGetter<List<int>?>? selectedExercises,
  }) {
    return StatsModel(
        period: period ?? this.period,
        startEnd: startEnd ?? this.startEnd,
        filter: filter ?? this.filter,
        baseSessions: baseSessions ?? this.baseSessions,
        selectedExercises: selectedExercises != null ? selectedExercises.call() : this.selectedExercises);
  }
}

class ExerciseDataStatsModel<T> {
  final String title;
  final Map<String, T> Function(BuildContext context) data;

  ExerciseDataStatsModel({
    required this.title,
    required this.data,
  });
}

class ExerciseStatsModel {
  final ExerciseModel exercise;
  final List<ExerciseDataStatsModel<LineChartModel>> data;

  ExerciseStatsModel({
    required this.exercise,
    required this.data,
  });

  ExerciseStatsModel.fromExercise({
    required this.exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) : data = getData(
          exercise: exercise,
          sessions: sessions,
          period: period,
          startEnd: startEnd,
        );

  static List<ExerciseDataStatsModel<LineChartModel>> getData({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    switch (exercise.type) {
      case ExerciseTypeEnum.reps:
        return getDataReps(exercise: exercise, sessions: sessions, period: period, startEnd: startEnd);
      case ExerciseTypeEnum.repsAndWeight:
        return getDataRepsAndWeight(exercise: exercise, sessions: sessions, period: period, startEnd: startEnd);
      case ExerciseTypeEnum.timeAndDistance:
        return getDataTimeAndDistance(exercise: exercise, sessions: sessions, period: period, startEnd: startEnd);
      case ExerciseTypeEnum.time:
        return getDataTime(exercise: exercise, sessions: sessions, period: period, startEnd: startEnd);
      case ExerciseTypeEnum.distance:
        return getDataDistance(exercise: exercise, sessions: sessions, period: period, startEnd: startEnd);
      default:
        return [];
    }
  }

  static Map<(DateTime, DateTime), List<ExerciseSetTrainingSessionModel>> getDatesSets(Map<(DateTime, DateTime), List<TrainingSessionModel>> dateSessions, ExerciseModel exercise) {
    return dateSessions.map(
      (key, value) => MapEntry(
        key,
        value.fold<List<ExerciseSetTrainingSessionModel>>(
          [],
          (p, e) => [
            ...p,
            ...e.exercises.fold(
              [],
              (p2, e2) => [
                ...p2,
                ...e2.exercises.where((element) => element.exercise.id == exercise.id).fold(
                  [],
                  (p3, e3) => [
                    ...p3,
                    ...e3.groupSets.fold(
                      [],
                      (p4, e4) => [
                        ...p4,
                        ...e4.sets.where(
                          (element) => element.done,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    )..removeWhere((key, value) => value.isEmpty);
  }

  static String getXAxisLabels(BuildContext context, int i, StatsPeriodEnum period, Map<(DateTime, DateTime), List<ExerciseSetTrainingSessionModel>> dateSets, int currentSkip, int currentZoom) {
    final dates = dateSets.entries.map((e) => e.key);
    final interval = currentZoom > 10 ? [currentSkip, ...List.generate(3, (i) => currentSkip + (((currentZoom - 2) / 4) * (i + 1)).toInt()), currentSkip + currentZoom - 1] : <int>[];
    if (i < 0) {
      return "";
    }
    return switch (period) {
      StatsPeriodEnum.week => dates.elementAt(i).$1.format(AppLocale.formatDateDayMonth.getTranslation(context)),
      // StatsPeriodEnum.month => [0, 14, (dates.elementAtOrNull(i)?.$2.lastDayOfMonth.day ?? 0) - 1].contains(i) ? dates.elementAt(i).$1.day.toString() : '',
      // StatsPeriodEnum.month => [0, 14, (dates.elementAtOrNull(i)?.$2.lastDayOfMonth.day ?? 0) - 1].contains(i) ? dates.elementAt(i).$1.day.toString() : '',
      StatsPeriodEnum.month => interval.isNotEmpty
          ? (interval.contains(i) ? dates.elementAt(i).$1.format(AppLocale.formatDateDayMonth.getTranslation(context)) : '')
          : dates.elementAt(i).$1.format(AppLocale.formatDateDayMonth.getTranslation(context)),
      StatsPeriodEnum.year => interval.isNotEmpty
          ? (interval.contains(i) ? dates.elementAt(i).$1.format(AppLocale.formatDateDayMonth.getTranslation(context)) : '')
          : dates.elementAt(i).$1.format(AppLocale.formatDateDayMonth.getTranslation(context)),
      _ => '',
    };
  }

  static List<ExerciseDataStatsModel<LineChartModel>> getDataReps({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = getDateLimits(period: period, startEnd: startEnd);
    final datesSessions = Map.fromEntries(dates.map((e) => MapEntry(e, sessions.where((element) => element.date.isBetween(e.$1, e.$2)).toList())));
    final dateSets = getDatesSets(datesSessions, exercise);

    return [
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalReps,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(
                  label: '',
                  values:
                      dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.fold(0, (p, e) => p + (e.meta as ExerciseSetMetaRepsTrainingSessionModel).reps), formattedValue: '')).toList(),
                  color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalSets,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(label: '', values: dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.length, formattedValue: '')).toList(), color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelAverageRepsPerSet,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.isEmpty ? 0 : (e.value.fold(0, (p, e) => p + (e.meta as ExerciseSetMetaRepsTrainingSessionModel).reps) / e.value.length), formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxRepsInOneset,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(value: e.value.fold(0, (p, e) => math.max(p, (e.meta as ExerciseSetMetaRepsTrainingSessionModel).reps)), formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
    ];
  }

  static List<ExerciseDataStatsModel<LineChartModel>> getDataRepsAndWeight({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = getDateLimits(period: period, startEnd: startEnd);
    final Map<(DateTime, DateTime), List<TrainingSessionModel>> datesSessions =
        Map.fromEntries(dates.map((e) => MapEntry(e, sessions.where((element) => element.date.isBetween(e.$1, e.$2)).toList())));
    final dateSets = getDatesSets(datesSessions, exercise);

    return [
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalReps,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(value: e.value.fold(0, (p, e) => p + (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel).reps), formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalSets,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(label: '', values: dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.length, formattedValue: '')).toList(), color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelAverageRepsPerSet,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.isEmpty ? 0 : (e.value.fold(0, (p, e) => p + (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel).reps) / e.value.length), formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxRepsInOneset,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(value: e.value.fold(0, (p, e) => math.max(p, (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel).reps)), formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ).replaceMaxY(),
        },
      ),
      ExerciseDataStatsModel(
          title: AppLocale.labelMaxWeightInOneSet,
          data: (context) => Map.fromEntries(WeightUnitEnum.values.map((weight) => MapEntry(
              weight.getLabel(context),
              LineChartModel(
                maxX: (dateSets.entries.length - 1).toDouble(),
                xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
                valueFormatter: (v) => v!.toStringAsFixed(1),
                items: [
                  LineChartItemModel(
                      label: '',
                      values: dateSets.entries
                          .map((s) => LineChartItemValueModel(
                              value: s.value.fold(0.0, (p, e) {
                                    final meta = (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel);
                                    return math.max(p, meta.weight * meta.weightUnit.toBase);
                                  }) *
                                  weight.fromBase,
                              formattedValue: ''))
                          .toList(),
                      color: Colors.transparent),
                ],
              ))))),
      ExerciseDataStatsModel(
          title: AppLocale.labelTotalVolume,
          data: (context) => Map.fromEntries(WeightUnitEnum.values.map((weight) => MapEntry(
              weight.getLabel(context),
              LineChartModel(
                maxX: (dateSets.entries.length - 1).toDouble(),
                xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
                valueFormatter: (v) => v!.toStringAsFixed(1),
                items: [
                  LineChartItemModel(
                      label: '',
                      values: dateSets.entries
                          .map((e) => LineChartItemValueModel(
                              value: e.value.fold(0.0, (p, e) {
                                    final meta = (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel);
                                    return p + (meta.weight * meta.weightUnit.toBase * meta.reps);
                                  }) *
                                  weight.fromBase,
                              formattedValue: ''))
                          .toList(),
                      color: Colors.transparent),
                ],
              ))))),
      ExerciseDataStatsModel(
          title: AppLocale.labelAverageVolumePerSet,
          data: (context) => Map.fromEntries(WeightUnitEnum.values.map((weight) => MapEntry(
              weight.getLabel(context),
              LineChartModel(
                maxX: (dateSets.entries.length - 1).toDouble(),
                xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
                valueFormatter: (v) => v!.toStringAsFixed(1),
                items: [
                  LineChartItemModel(
                      label: '',
                      values: dateSets.entries
                          .map((e) => LineChartItemValueModel(
                              value: e.value.isEmpty
                                  ? 0
                                  : (e.value.fold(0.0, (p, e) {
                                            final meta = (e.meta as ExerciseSetMetaRepsAndWeightTrainingSessionModel);
                                            return p + (meta.weight * meta.weightUnit.toBase * meta.reps);
                                          }) *
                                          weight.fromBase) /
                                      e.value.length,
                              formattedValue: ''))
                          .toList(),
                      color: Colors.transparent),
                ],
              ))))),
    ];
  }

  static List<ExerciseDataStatsModel<LineChartModel>> getDataTimeAndDistance({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = getDateLimits(period: period, startEnd: startEnd);
    final Map<(DateTime, DateTime), List<TrainingSessionModel>> datesSessions =
        Map.fromEntries(dates.map((e) => MapEntry(e, sessions.where((element) => element.date.isBetween(e.$1, e.$2)).toList())));
    final dateSets = getDatesSets(datesSessions, exercise);

    return [
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalSets,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(label: '', values: dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.length, formattedValue: '')).toList(), color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalTime,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return p + (meta.duration);
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return p + (meta.duration);
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxTimeInOneSet,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return Duration(seconds: math.max(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return Duration(seconds: math.max(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMinTimeInOneSet,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold((e.value.firstOrNull?.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel?)?.duration ?? Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return Duration(seconds: math.min(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold((e.value.firstOrNull?.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel?)?.duration ?? Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                return Duration(seconds: math.min(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
          title: AppLocale.labelTotalDistance,
          data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
              distance.getLabelShort(context),
              LineChartModel(
                maxX: (dateSets.entries.length - 1).toDouble(),
                xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
                valueFormatter: (v) => v!.toStringAsFixed(1),
                items: [
                  LineChartItemModel(
                      label: '',
                      values: dateSets.entries
                          .map((e) => LineChartItemValueModel(
                              value: e.value.fold(0.0, (p, e) {
                                    final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                    return p + (meta.distance) * meta.unit.toBase;
                                  }) *
                                  distance.fromBase,
                              formattedValue: ''))
                          .toList(),
                      color: Colors.transparent),
                ],
              ))))),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxDistanceInOneSet,
        data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
            distance.getLabelShort(context),
            LineChartModel(
              maxX: (dateSets.entries.length - 1).toDouble(),
              xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
              valueFormatter: (v) => v!.toStringAsFixed(1),
              items: [
                LineChartItemModel(
                    label: '',
                    values: dateSets.entries
                        .map((e) => LineChartItemValueModel(
                            value: e.value.fold(0.0, (p, e) {
                                  final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                  return math.max(p, (meta.distance) * meta.unit.toBase);
                                }) *
                                distance.fromBase,
                            formattedValue: ''))
                        .toList(),
                    color: Colors.transparent),
              ],
            )))),
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMinDistanceInOneSet,
        data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
            distance.getLabelShort(context),
            LineChartModel(
              maxX: (dateSets.entries.length - 1).toDouble(),
              xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
              valueFormatter: (v) => v!.toStringAsFixed(1),
              items: [
                LineChartItemModel(
                    label: '',
                    values: dateSets.entries
                        .map((e) => LineChartItemValueModel(
                            value: e.value.fold(
                                    ((e.value.firstOrNull?.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel?)?.distance ?? 0.0) *
                                        (((e.value.firstOrNull?.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel?)?.unit.toBase ?? 1)), (p, e) {
                                  final meta = (e.meta as ExerciseSetMetaTimeAndDistanceTrainingSessionModel);
                                  return math.max(p, (meta.distance) * meta.unit.toBase);
                                }) *
                                distance.fromBase,
                            formattedValue: ''))
                        .toList(),
                    color: Colors.transparent),
              ],
            )))),
      ),
    ];
  }

  static List<ExerciseDataStatsModel<LineChartModel>> getDataTime({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = getDateLimits(period: period, startEnd: startEnd);
    final Map<(DateTime, DateTime), List<TrainingSessionModel>> datesSessions =
        Map.fromEntries(dates.map((e) => MapEntry(e, sessions.where((element) => element.date.isBetween(e.$1, e.$2)).toList())));
    final dateSets = getDatesSets(datesSessions, exercise);

    return [
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalSets,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(label: '', values: dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.length, formattedValue: '')).toList(), color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalTime,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return p + (meta.duration);
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return p + (meta.duration);
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxTimeInOneSet,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return Duration(seconds: math.max(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold(Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return Duration(seconds: math.max(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMinTimeInOneSet,
        data: (context) => {
          AppLocale.labelHourShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold((e.value.firstOrNull?.meta as ExerciseSetMetaTimeTrainingSessionModel?)?.duration ?? Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return Duration(seconds: math.min(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              360,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
          AppLocale.labelMinuteShort.getTranslation(context): LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(1),
            items: [
              LineChartItemModel(
                  label: '',
                  values: dateSets.entries
                      .map((e) => LineChartItemValueModel(
                          value: e.value.fold((e.value.firstOrNull?.meta as ExerciseSetMetaTimeTrainingSessionModel?)?.duration ?? Duration.zero, (p, e) {
                                final meta = (e.meta as ExerciseSetMetaTimeTrainingSessionModel);
                                return Duration(seconds: math.min(p.inSeconds, meta.duration.inSeconds));
                              }).inSeconds /
                              60,
                          formattedValue: ''))
                      .toList(),
                  color: Colors.transparent),
            ],
          ),
        },
      ),
    ];
  }

  static List<ExerciseDataStatsModel<LineChartModel>> getDataDistance({
    required ExerciseModel exercise,
    required List<TrainingSessionModel> sessions,
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = getDateLimits(period: period, startEnd: startEnd);
    final Map<(DateTime, DateTime), List<TrainingSessionModel>> datesSessions =
        Map.fromEntries(dates.map((e) => MapEntry(e, sessions.where((element) => element.date.isBetween(e.$1, e.$2)).toList())));
    final dateSets = getDatesSets(datesSessions, exercise);

    return [
      ExerciseDataStatsModel(
        title: AppLocale.labelTotalSets,
        data: (context) => {
          '': LineChartModel(
            maxX: (dateSets.entries.length - 1).toDouble(),
            xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
            valueFormatter: (v) => v!.toStringAsFixed(0),
            items: [
              LineChartItemModel(label: '', values: dateSets.entries.map((e) => LineChartItemValueModel(value: e.value.length, formattedValue: '')).toList(), color: Colors.transparent),
            ],
          ),
        },
      ),
      ExerciseDataStatsModel(
          title: AppLocale.labelTotalDistance,
          data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
              distance.getLabelShort(context),
              LineChartModel(
                maxX: (dateSets.entries.length - 1).toDouble(),
                xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
                valueFormatter: (v) => v!.toStringAsFixed(1),
                items: [
                  LineChartItemModel(
                      label: '',
                      values: dateSets.entries
                          .map((e) => LineChartItemValueModel(
                              value: e.value.fold(0.0, (p, e) {
                                    final meta = (e.meta as ExerciseSetMetaDistanceTrainingSessionModel);
                                    return p + (meta.distance) * meta.unit.toBase;
                                  }) *
                                  distance.fromBase,
                              formattedValue: ''))
                          .toList(),
                      color: Colors.transparent),
                ],
              ))))),
      ExerciseDataStatsModel(
        title: AppLocale.labelMaxDistanceInOneSet,
        data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
            distance.getLabelShort(context),
            LineChartModel(
              maxX: (dateSets.entries.length - 1).toDouble(),
              xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
              valueFormatter: (v) => v!.toStringAsFixed(1),
              items: [
                LineChartItemModel(
                    label: '',
                    values: dateSets.entries
                        .map((e) => LineChartItemValueModel(
                            value: e.value.fold(0.0, (p, e) {
                                  final meta = (e.meta as ExerciseSetMetaDistanceTrainingSessionModel);
                                  return math.max(p, (meta.distance) * meta.unit.toBase);
                                }) *
                                distance.fromBase,
                            formattedValue: ''))
                        .toList(),
                    color: Colors.transparent),
              ],
            )))),
      ),
      ExerciseDataStatsModel(
        title: AppLocale.labelMinDistanceInOneSet,
        data: (context) => Map.fromEntries(DistanceUnitEnum.values.map((distance) => MapEntry(
            distance.getLabelShort(context),
            LineChartModel(
              maxX: (dateSets.entries.length - 1).toDouble(),
              xAxisLabels: (context, i, cs, cz) => getXAxisLabels(context, i, period, dateSets, cs, cz),
              valueFormatter: (v) => v!.toStringAsFixed(1),
              items: [
                LineChartItemModel(
                    label: '',
                    values: dateSets.entries
                        .map((e) => LineChartItemValueModel(
                            value: e.value.fold(
                                    ((e.value.firstOrNull?.meta as ExerciseSetMetaDistanceTrainingSessionModel?)?.distance ?? 0.0) *
                                        (((e.value.firstOrNull?.meta as ExerciseSetMetaDistanceTrainingSessionModel?)?.unit.toBase ?? 1)), (p, e) {
                                  final meta = (e.meta as ExerciseSetMetaDistanceTrainingSessionModel);
                                  return math.max(p, (meta.distance) * meta.unit.toBase);
                                }) *
                                distance.fromBase,
                            formattedValue: ''))
                        .toList(),
                    color: Colors.transparent),
              ],
            )))),
      ),
    ];
  }

  static List<(DateTime, DateTime)> getDateLimits({
    required StatsPeriodEnum period,
    required (DateTime, DateTime) startEnd,
  }) {
    final dates = switch (period) {
      StatsPeriodEnum.week => startEnd.$1.getDaysUntil(end: startEnd.$2).map((e) => (e, e)).toList(),
      StatsPeriodEnum.month => startEnd.$1.getDaysUntil(end: startEnd.$2).map((e) => (e, e)).toList(),
      StatsPeriodEnum.year => startEnd.$1.getDaysUntil(end: startEnd.$2).map((e) => (e, e)).toList(),
      // StatsPeriodEnum.year => LstartEnd.$1.getDaysUntil(end: startEnd.$2).map((e) => (e, e)).toList()ist.generate(DateTime.monthsPerYear, (index) => DateTime(startEnd.$1.year, index + 1, 1)).map((e) => (e, e.lastDayOfMonth)).toList(),
      StatsPeriodEnum.all => startEnd.$1.getDaysUntil(end: startEnd.$2).map((e) => (e, e)).toList(),
    };

    return dates;
  }
}

// class StatsSessionItemModel {
//   final DateTime date;
//   final Duration duration;
//   final List<StatsExerciseItemModel> exercises;
// }

// class StatsExerciseItemModel {
//   final int id;
//   final int tagId;
//   final ExerciseTypeEnum type;
//   final ExerciseSetMetaTrainingSessionModel meta;

//   StatsExerciseItemModel({
//     required this.id,
//     required this.type,
//     required this.tagId,
//     required this.meta,
//   });
// }
