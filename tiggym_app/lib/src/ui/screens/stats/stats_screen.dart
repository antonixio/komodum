import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/data/repository/exercise_repository/exercise_repository.dart';
import 'package:tiggym/src/data/repository/stats_repository/stats_repository.dart';
import 'package:tiggym/src/data/repository/tag_repository/tag_repository.dart';
import 'package:tiggym/src/ui/widgets/c_tag_item/c_tag_item_widget.dart';
import 'package:tiggym/src/util/extensions/build_context_extensions.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../data/enums/stats_period_enum.dart';
import '../../../data/models/stats_model.dart';
import '../../widgets/c_charts/c_bar_chart_widget.dart';
import '../../widgets/c_charts/c_line_chart_widget.dart';
import '../../widgets/c_heatmap/c_heatmap.dart';
import '../../widgets/c_shareable/c_shareable_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final stats = BehaviorSubject<LoadableDataModel<StatsModel?>>.seeded(LoadableDataModel.loading());
  final statsRepository = GetIt.I.get<StatsRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(seconds: 1));
      final value = await statsRepository.getData();
      stats.add(LoadableDataModel.success(data: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
        ),
        body: StreamBuilder(
            stream: stats,
            builder: (context, snapshot) {
              final data = snapshot.data?.data;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  // addAutomaticKeepAlives: true,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...[
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              context.showMaterialModalBottomSheet((context) => CFilterExercisesWidget(
                                    selectedExercises: data.selectedExercises ?? <int>[],
                                    onChanged: (selected) {
                                      stats.add(LoadableDataModel.success(data: data.copyWith(selectedExercises: () => selected)));
                                    },
                                  ));
                            },
                            icon: const Icon(Icons.filter_alt),
                          ),
                          const Gap(16),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: data.selectedExerciseList
                                    .map<Widget>((e) => Chip(
                                          clipBehavior: Clip.antiAlias,
                                          onDeleted: () {
                                            stats.add(LoadableDataModel.success(
                                                data: data.copyWith(selectedExercises: () => data.selectedExerciseList.where((element) => element.id != e.id).map((e) => e.id).toList())));
                                          },
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 12,
                                          ),
                                          deleteIconColor: Theme.of(context).colorScheme.primary,
                                          // onPressed: () {},
                                          label: Text(e.getName(context)),
                                          backgroundColor: Theme.of(context).colorScheme.surface,
                                          padding: const EdgeInsets.all(8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                            side: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .addBetween(const Gap(8))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      SegmentedButton<StatsPeriodEnum>(
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                        showSelectedIcon: false,
                        segments: StatsPeriodEnum.values
                            .where((element) => element != StatsPeriodEnum.all)
                            .map((e) => ButtonSegment(
                                  value: e,
                                  label: Text(e.getLabel(context)),
                                ))
                            .toList(),
                        selected: {data.period},
                        onSelectionChanged: (v) {
                          final value = v.first;
                          if (value != data.period) {
                            stats.add(LoadableDataModel.success(data: data.changePeriod(period: value)));
                          }
                        },
                      ),
                      const Gap(16),
                      CShareableWidget(
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Gap(16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  AppLocale.labelHomeFrequency.getTranslation(context),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Gap(16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: CHeatMap(
                                  defaultColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(data.period != StatsPeriodEnum.all ? 0.2 : 1),
                                  startAt: DateTime.now().copyWith(day: 1, month: 1, year: DateTime.now().year - 5),
                                  datasets: data.heatmapData,
                                  colorsets: {
                                    1: Theme.of(context).colorScheme.surfaceVariant,
                                    2: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    3: Theme.of(context).colorScheme.primary,
                                  },
                                ),
                              ),
                              const Gap(12),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          IconButton(
                              onPressed: data.canGoPrevious
                                  ? () {
                                      stats.add(LoadableDataModel.success(data: data.previousPeriod()));
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left)),
                          Expanded(
                            child: Text(
                              data.periodText(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                              onPressed: data.canGoNext
                                  ? () {
                                      stats.add(LoadableDataModel.success(data: data.nextPeriod()));
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right)),
                        ],
                      ),
                      const Gap(16),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocale.labelSessions.getTranslation(context),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const Gap(4),
                                      Text(data.sessionsInPeriod.toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Material(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocale.labelAverageSessionTime.getTranslation(context),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const Gap(4),
                                      Text(data.averageSessionTime.hoursMinutesSeconds),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocale.labelExercisesPerSession.getTranslation(context),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const Gap(4),
                                      Text(data.exercisesPerSession.toStringAsFixed(1)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Material(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocale.labelSetsPerSession.getTranslation(context),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const Gap(4),
                                      Text(data.setsPerSession.toStringAsFixed(1)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(32),
                      CShareableWidget(
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CBarChartWidget(
                                  // maxY: 10,
                                  // interval: 10,
                                  title: AppLocale.labelWeeklyDistribution.getTranslation(context),
                                  data: BarChartModel(
                                    items: data.weeklyDistribution.entries
                                        .map((e) => BarChartItemModel(
                                              label: e.key.toString(),
                                              color: Theme.of(context).colorScheme.primary,
                                              values: [BarChartItemValueModel.fromInt(value: e.value)],
                                            ))
                                        .toList(),
                                    xAxisLabels: data.weeklyDistribution.entries.map((entry) => DateTime(1970, 2, entry.key).format("EEE").substring(0, 2)).toList(),
                                    valueFormatter: (v) => v!.toStringAsFixed(0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(32),
                    ].map((e) => e is Gap
                        ? e
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: e,
                          )),
                    ...data.exercisesStats
                        .groupBy((p0) => p0.exercise.tag?.mainTag ?? false ? (p0.exercise.tag?.id ?? 0) : (p0.exercise.tag?.mainTagId ?? 0))
                        .entries
                        // .where((element) => [
                        //       ExerciseTypeEnum.time,
                        //       ExerciseTypeEnum.distance,
                        //       ExerciseTypeEnum.timeAndDistance,
                        //       ExerciseTypeEnum.reps,
                        //       ExerciseTypeEnum.repsAndWeight,
                        //     ].contains(element.exercise.type))
                        .map<Widget>((e) {
                      final mainTag = GetIt.I.get<TagRepository>().tagCategories.value.firstWhereOrNull((element) => element.mainTag.id == e.key);
                      return Column(
                        children: [
                          if (mainTag != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.label,
                                    size: 12,
                                    color: mainTag.mainTag.color,
                                  ),
                                  const Gap(4),
                                  Text(
                                    mainTag.mainTag.getName(context),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                          ],
                          ...e.value
                              .map<Widget>((e) => ExerciseStatsWidget(
                                    exerciseStats: e,
                                    stats: data,
                                  ))
                              .toList()
                              .addBetween(const Gap(16))
                        ],
                      );
                    }).addBetween(const Gap(16)),
                    const Gap(16),
                  ],
                ),
              );
            }));
  }
}

class CFilterExercisesWidget extends StatefulWidget {
  final List<int> selectedExercises;
  final void Function(List<int>) onChanged;
  const CFilterExercisesWidget({
    super.key,
    required this.selectedExercises,
    required this.onChanged,
  });

  @override
  State<CFilterExercisesWidget> createState() => _CFilterExercisesWidgetState();
}

class _CFilterExercisesWidgetState extends State<CFilterExercisesWidget> {
  final exercises = GetIt.I.get<ExerciseRepository>().data.value;
  final search = BehaviorSubject.seeded('');

  late final filteredExercises = search.map((a) {
    if (a.isNotEmpty) {
      return exercises.where((element) => element.getName(context).toUpperCase().contains(a.toUpperCase()) || (element.tag?.getName(context) ?? '').toUpperCase().contains(a.toUpperCase())).toList();
    }

    return exercises;
  }).shareValueSeeded(exercises);

  late final selected = BehaviorSubject.seeded(widget.selectedExercises);
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.onChanged.call(selected.value);
      },
      child: SafeArea(
        // constraints: const BoxConstraints(maxHeight: 400),
        child: Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
          ),
          body: StreamBuilder(
              stream: filteredExercises,
              initialData: filteredExercises.value,
              builder: (context, snapshot) {
                final data = (snapshot.data ?? <ExerciseModel>[]).where((element) => element.deletedAt == null).toList();

                return ListView(shrinkWrap: true, padding: const EdgeInsets.all(0), children: [
                  StreamBuilder(
                      stream: selected,
                      initialData: selected.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile.adaptive(
                          value: exercises.every((element) => (snapshot.data ?? <int>[]).contains(element.id)),
                          onChanged: (v) {
                            if (v ?? false) {
                              selected.add(exercises.map((e) => e.id).toList());
                            } else {
                              selected.add(<int>[]);
                            }
                          },
                          title: Text(AppLocale.labelAll.getTranslation(context)),
                        );
                      }),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      onChanged: (v) {
                        search.add(v);
                        // tag.add(tag.value.copyWith(name: v));
                      },
                      decoration: InputDecoration(
                        hintText: AppLocale.labelSearch.getTranslation(context),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Gap(16),
                  ...data
                      .map(
                        (e) => StreamBuilder(
                            stream: selected,
                            initialData: selected.value,
                            builder: (context, snapshot) {
                              return CheckboxListTile.adaptive(
                                value: snapshot.data?.contains(e.id) ?? false,
                                onChanged: (v) {
                                  if (snapshot.data?.contains(e.id) ?? false) {
                                    selected.add([...snapshot.data ?? <int>[]]..remove(e.id));
                                  } else {
                                    selected.add([...snapshot.data ?? <int>[], e.id]);
                                  }
                                },
                                title: Text(
                                  e.getName(context),
                                ),
                                subtitle: e.tag != null ? Align(alignment: Alignment.centerLeft, child: CTagItemWidget(tag: e.tag!)) : null,
                              );
                            }),
                      )
                      .toList(),
                ]);
              }),
        ),
      ),
    );
  }
}

class ExerciseStatsWidget extends StatefulWidget {
  final ExerciseStatsModel exerciseStats;
  final StatsModel stats;
  const ExerciseStatsWidget({
    super.key,
    required this.exerciseStats,
    required this.stats,
  });

  @override
  State<ExerciseStatsWidget> createState() => _ExerciseStatsWidgetState();
}

class _ExerciseStatsWidgetState extends State<ExerciseStatsWidget> {
  int currentPage = 0;
  final PageController pageController = PageController(keepPage: true, viewportFraction: 1);
  @override
  Widget build(BuildContext context) {
    final tag = widget.exerciseStats.exercise.tag;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.showMaterialModalBottomSheet((context) => CExerciseStatsDetailsWidget(
                  exerciseStats: widget.exerciseStats,
                  stats: widget.stats,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseStats.exercise.getName(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (tag != null) CTagItemWidget(tag: tag),
                      // SizedBox(
                      //   // color: Colors.red,
                      //   height: height + 108,
                      //   child: PageView(
                      //     onPageChanged: (p) {
                      //       setState(() {
                      //         currentPage = p;
                      //       });
                      //     },
                      //     controller: pageController,
                      //     children: widget.exerciseStats.data.map((e) {
                      //       return CExerciseChartWidget(exerciseStats: widget.exerciseStats, exerciseDataStats: e);
                      //     }).toList(),
                      //   ),
                      // ),
                      // const Gap(8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List<Widget>.generate(
                      //     widget.exerciseStats.data.length,
                      //     (i) => Container(
                      //       decoration: BoxDecoration(color: Theme.of(context).colorScheme.onBackground.withOpacity(currentPage == i ? 1 : 0.4), borderRadius: BorderRadius.circular(100)),
                      //       width: 6,
                      //       height: 6,
                      //     ),
                      //   ).addBetween(const Gap(6)).toList(),
                      // )
                    ],
                  ),
                ),
                const Icon(
                  Icons.analytics,
                  size: 16,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CExerciseStatsDetailsWidget extends StatefulWidget {
  final StatsModel stats;
  final ExerciseStatsModel exerciseStats;

  const CExerciseStatsDetailsWidget({super.key, required this.exerciseStats, required this.stats});

  @override
  State<CExerciseStatsDetailsWidget> createState() => _CExerciseStatsDetailsWidgetState();
}

class _CExerciseStatsDetailsWidgetState extends State<CExerciseStatsDetailsWidget> {
  late final stats = BehaviorSubject<StatsModel>.seeded(widget.stats.copyWith(selectedExercises: () => [widget.exerciseStats.exercise.id]));

  @override
  Widget build(BuildContext context) {
    final tag = widget.exerciseStats.exercise.tag;
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true),
      body: SafeArea(
          child: ListView(
        children: [
          ...[
            Text(
              widget.exerciseStats.exercise.getName(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),
            if (tag != null) ...[
              Align(alignment: Alignment.centerLeft, child: CTagItemWidget(tag: tag)),
              const Gap(32),
            ],
            StreamBuilder(
                stream: stats,
                initialData: stats.value,
                builder: (context, snapshot) {
                  final data = snapshot.data!;
                  return SegmentedButton<StatsPeriodEnum>(
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                      selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    showSelectedIcon: false,
                    segments: StatsPeriodEnum.values
                        .where((element) => element != StatsPeriodEnum.all)
                        .map((e) => ButtonSegment(
                              value: e,
                              label: Text(e.getLabel(context)),
                            ))
                        .toList(),
                    selected: {data.period},
                    onSelectionChanged: (v) {
                      final value = v.first;
                      if (value != data.period) {
                        stats.add(data.changePeriod(period: value));
                      }
                    },
                  );
                }),
            const Gap(16),
            StreamBuilder(
                stream: stats,
                initialData: stats.value,
                builder: (context, snapshot) {
                  final data = snapshot.data!;
                  return CShareableWidget(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              widget.exerciseStats.exercise.getName(context),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Gap(16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CHeatMap(
                              defaultColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(data.period != StatsPeriodEnum.all ? 0.2 : 1),
                              startAt: DateTime.now().copyWith(day: 1, month: 1, year: DateTime.now().year - 5),
                              datasets: data.heatmapData,
                              colorsets: {
                                1: Theme.of(context).colorScheme.surfaceVariant,
                                2: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                3: Theme.of(context).colorScheme.primary,
                              },
                            ),
                          ),
                          const Gap(12),
                        ],
                      ),
                    ),
                  );
                }),
            const Gap(32),
            StreamBuilder(
                stream: stats,
                initialData: stats.value,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return Row(
                    children: [
                      IconButton(
                          onPressed: data?.canGoPrevious ?? false
                              ? () {
                                  stats.add(data!.previousPeriod());
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left)),
                      Expanded(
                        child: Text(
                          data!.periodText(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                          onPressed: data.canGoNext
                              ? () {
                                  stats.add(data.nextPeriod());
                                }
                              : null,
                          icon: const Icon(Icons.chevron_right)),
                    ],
                  );
                }),
            const Gap(32),
            StreamBuilder(
                stream: stats,
                initialData: stats.value,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocale.labelSessions.getTranslation(context),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Gap(4),
                                  Text((data?.sessionsInPeriod ?? 0).toStringAsFixed(1)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocale.labelSetsPerSession.getTranslation(context),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Gap(4),
                                  Text((data?.setsPerSession ?? 0).toStringAsFixed(1)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ].map((e) => e is Gap || e is CExerciseChartWidget
              ? e
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: e,
                )),
          const Gap(32),
          StreamBuilder(
              stream: stats,
              initialData: stats.value,
              builder: ((context, snapshot) {
                final data = snapshot.data;
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  const Gap(32),
                  ...data!.exercisesStats.first.data.map<Widget>((e) => CExerciseChartWidget(exerciseStats: data.exercisesStats.first, exerciseDataStats: e)).addBetween(const Gap(16)),
                ]);
              })),
          // StreamBuilder(stream: stream, builder: builder)
          // ...widget.exerciseStats.data.map<Widget>((e) {
          //   return StreamBuilder(
          //       stream: stats,
          //       initialData: stats.value,
          //       builder: (context, snapshot) {
          //         return CExerciseChartWidget(exerciseStats: snapshot.data!.exercisesStats.first, exerciseDataStats: e);
          //       });
          // }).addBetween(const Gap(16)),
          const Gap(32),
        ],
      )),
    );
  }
}

class CExerciseChartWidget extends StatefulWidget {
  final ExerciseStatsModel exerciseStats;
  final ExerciseDataStatsModel<LineChartModel> exerciseDataStats;
  const CExerciseChartWidget({
    super.key,
    required this.exerciseStats,
    required this.exerciseDataStats,
  });

  @override
  State<CExerciseChartWidget> createState() => _CExerciseChartWidgetState();
}

class _CExerciseChartWidgetState extends State<CExerciseChartWidget> {
  final view = BehaviorSubject<String?>.seeded(null);
  @override
  Widget build(BuildContext context) {
    final tag = widget.exerciseStats.exercise.tag;
    final items = widget.exerciseDataStats.data.call(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            StreamBuilder(
                stream: view,
                initialData: view.value,
                builder: (context, snapshot) {
                  final selectedView = items.entries.map((e) => e.key).firstWhere((e) => e == snapshot.data, orElse: () => items.entries.first.key);
                  return CShareableWidget(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.exerciseStats.exercise.getName(context),
                              maxLines: 1,
                            ),
                            if (tag != null) CTagItemWidget(tag: tag),
                            const Gap(16),
                            Row(
                              children: [
                                Text(
                                  widget.exerciseDataStats.title.getTranslation(context),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            if (items.entries.length > 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: SegmentedButton<String>(
                                  style: SegmentedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                      selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                                      selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                                      fixedSize: const Size.square(0),
                                      minimumSize: const Size.square(0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  showSelectedIcon: false,
                                  segments: items.entries
                                      .map((e) => ButtonSegment(
                                            value: e.key,
                                            label: Text(e.key),
                                          ))
                                      .toList(),
                                  multiSelectionEnabled: false,
                                  selected: {selectedView},
                                  onSelectionChanged: (v) {
                                    view.add(v.first);
                                    // final value = v.first;
                                    // if (value != data.period) {
                                    //   stats.add(LoadableDataModel.success(data: data.changePeriod(period: value)));
                                    // }
                                  },
                                ),
                              ),
                            if (items.entries.length <= 1) const Gap(16),
                            CLineChartWidget(
                              currentZoom: items[selectedView]?.maxX.toInt(),
                              maxY: items[selectedView]?.maxY,
                              // interval: 10,
                              // title: "Sessões por dia de semana",
                              // maxY: e.data.entries.first.value.maxX,
                              // interval: e.data.entries.,
                              data: items[selectedView]!.copyWith(items: items[selectedView]!.items.map((i) => i.copyWith(color: Theme.of(context).colorScheme.primary)).toList()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
