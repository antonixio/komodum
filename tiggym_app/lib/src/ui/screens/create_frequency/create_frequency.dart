import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tiggym/src/data/repository/exercise_repository/exercise_repository.dart';
import 'package:tiggym/src/data/repository/stats_repository/stats_repository.dart';
import 'package:tiggym/src/ui/widgets/c_tag_item/c_tag_item_widget.dart';
import 'package:tiggym/src/util/extensions/build_context_extensions.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../data/enums/stats_period_enum.dart';
import '../../../data/models/stats_model.dart';
import '../../widgets/c_charts/c_bar_chart_widget.dart';
import '../../widgets/c_charts/c_line_chart_widget.dart';
import '../../widgets/c_heatmap/c_heatmap.dart';
import '../../widgets/c_shareable/c_shareable_widget.dart';

class _FrequencyModel {
  final List<DateTime> dates;
  final String title;

  _FrequencyModel({
    required this.dates,
    required this.title,
  });

  _FrequencyModel copyWith({
    List<DateTime>? dates,
    String? title,
  }) {
    return _FrequencyModel(
      dates: dates ?? this.dates,
      title: title ?? this.title,
    );
  }
}

class CreateFrequencyScreen extends StatefulWidget {
  const CreateFrequencyScreen({super.key});

  @override
  State<CreateFrequencyScreen> createState() => _CreateFrequencyScreenState();
}

class _CreateFrequencyScreenState extends State<CreateFrequencyScreen> {
  final frequency = BehaviorSubject.seeded(_FrequencyModel(dates: [], title: 'Title'));
  String fillRandom = '';
  String fill = '';
  String clear = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          StreamBuilder(
              stream: frequency,
              initialData: frequency.value,
              builder: (context, snapshot) {
                return CShareableWidget(
                  showIcon: false,
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
                            snapshot.data?.title ?? '',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: CHeatMap(
                            defaultColor: Theme.of(context).colorScheme.surfaceVariant,
                            startAt: DateTime.now().copyWith(year: DateTime.now().year - 2),
                            datasets: Map.fromEntries(snapshot.data?.dates.map((e) => MapEntry(e, 1)) ?? []),
                            colorsets: {
                              1: Theme.of(context).colorScheme.primary,
                            },
                          ),
                        ),
                        const Gap(12),
                      ],
                    ),
                  ),
                );
              }),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    fillRandom = v;
                  },
                ),
              ),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        final splited = fillRandom.split(".");
                        final weekday = splited.length <= 1 ? 0 : int.tryParse(splited.firstOrNull ?? '');
                        final count = int.tryParse(splited.lastOrNull ?? '');

                        var dates =
                            DateTime.now().copyWith(year: DateTime.now().year - 2).getDaysUntil(end: DateTime.now()).where((element) => element.weekday == weekday || (weekday ?? 0) == 0).toList();
                        final length = min(dates.length, count ?? 0);
                        final randomDates = <DateTime>[];
                        for (var i = 0; i < length; i++) {
                          final random = dates.randomItem();
                          randomDates.add(random!);
                          dates.remove(random);
                        }
                        var keepDates = (weekday ?? 0) == 0 ? <DateTime>[] : frequency.value.dates.where((element) => element.weekday != weekday);
                        frequency.add(frequency.value.copyWith(dates: [...keepDates, ...randomDates]));
                      },
                      child: const Text("Random Fill"))),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    fill = v;
                  },
                ),
              ),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        final weekday = int.tryParse(fill);

                        var dates =
                            DateTime.now().copyWith(year: DateTime.now().year - 2).getDaysUntil(end: DateTime.now()).where((element) => element.weekday == weekday || (weekday ?? 0) == 0).toList();
                        var keepDates = (weekday ?? 0) == 0 ? <DateTime>[] : frequency.value.dates.where((element) => element.weekday != weekday);
                        frequency.add(frequency.value.copyWith(dates: [...keepDates, ...dates]));
                      },
                      child: const Text("Fill"))),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    clear = v;
                  },
                ),
              ),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        final weekday = int.tryParse(clear);

                        var dates = frequency.value.dates.where((element) => (weekday ?? 0) == 0 ? false : element.weekday != weekday).toList();

                        frequency.add(frequency.value.copyWith(dates: dates));
                      },
                      child: const Text("Clear"))),
            ],
          ),
          const Gap(16),
          StreamBuilder(
              stream: frequency,
              initialData: frequency.value,
              builder: (_, snapshot) {
                return TextFormField(
                  initialValue: snapshot.data?.title,
                  onChanged: (v) => frequency.add(snapshot.data!.copyWith(title: v)),
                  decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: "Title",
                  ),
                );
              }),
          const Gap(16),
          StreamBuilder(
              stream: frequency,
              initialData: frequency.value,
              builder: (context, snapshot) {
                return TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                  eventLoader: (day) => snapshot.data?.dates.contains(day.dateOnly) ?? false ? [1] : <int>[],
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      return events.isNotEmpty
                          ? Center(
                              child: Opacity(
                                  opacity: 0.2,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                  )))
                          : null;
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return Center(child: Text(day.day.toString()));
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Center(child: Text(day.day.toString()));
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      return Center(child: Text(day.day.toString()));
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (snapshot.data?.dates.contains(selectedDay.dateOnly) ?? false) {
                      frequency.add(frequency.value.copyWith(dates: frequency.value.dates..remove(selectedDay.dateOnly)));
                    } else {
                      frequency.add(frequency.value.copyWith(dates: frequency.value.dates..add(selectedDay.dateOnly)));
                    }
                  },
                  availableCalendarFormats: const {CalendarFormat.month: 'month'},
                  availableGestures: AvailableGestures.horizontalSwipe,
                );
              }),
        ],
      ),
    );
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
  const ExerciseStatsWidget({
    super.key,
    required this.exerciseStats,
  });

  @override
  State<ExerciseStatsWidget> createState() => _ExerciseStatsWidgetState();
}

class _ExerciseStatsWidgetState extends State<ExerciseStatsWidget> {
  int currentPage = 0;
  final PageController pageController = PageController(keepPage: true, viewportFraction: 1);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxWidth / (16 / 9);
      return Column(
        children: [
          SizedBox(
            // color: Colors.red,
            height: height + 108,
            child: PageView(
              onPageChanged: (p) {
                setState(() {
                  currentPage = p;
                });
              },
              controller: pageController,
              children: widget.exerciseStats.data.map((e) {
                return CExerciseChartWidget(exerciseStats: widget.exerciseStats, exerciseDataStats: e);
              }).toList(),
            ),
          ),
          // const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              widget.exerciseStats.data.length,
              (i) => Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onBackground.withOpacity(currentPage == i ? 1 : 0.4), borderRadius: BorderRadius.circular(100)),
                width: 6,
                height: 6,
              ),
            ).addBetween(const Gap(6)).toList(),
          )
        ],
      );
    });
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
