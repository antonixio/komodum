import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CDateTimeSelector extends StatefulWidget {
  final DateTime date;
  const CDateTimeSelector({
    super.key,
    required this.date,
  });

  @override
  State<CDateTimeSelector> createState() => _CDateTimeSelectorState();
}

class _CDateTimeSelectorState extends State<CDateTimeSelector> {
  late final hours = BehaviorSubject.seeded(widget.date.hour);
  late final minutes = BehaviorSubject.seeded(widget.date.minute);
  late final seconds = BehaviorSubject.seeded(widget.date.second);
  late final day = BehaviorSubject.seeded(widget.date.day);
  late final month = BehaviorSubject.seeded(widget.date.month);
  late final year = BehaviorSubject.seeded(widget.date.year);
  late final lastDayOfMonth = BehaviorSubject.seeded(widget.date.lastDayOfMonth);
  late final date = Rx.combineLatest3(year, month, day, (a, b, c) {
    final date = DateTime(a, b, c);
    final lastDayOfMonth = DateTime(a, b).lastDayOfMonth;
    return date.isAfter(lastDayOfMonth) ? lastDayOfMonth : date;
  }).shareValueSeeded(widget.date);

  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    subscriptions.add(date.listen((value) {
      final date = DateTime(value.year, value.month, day.value);

      if (date.day != day.value) {
        day.add(value.day);
      }
      final currentLastDay = lastDayOfMonth.value;
      if (currentLastDay.day != date.lastDayOfMonth.day) {
        lastDayOfMonth.add(date.lastDayOfMonth);
      }
    }));
    super.initState();
  }

  @override
  void dispose() {
    for (var element in subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    surface: Colors.transparent,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                    // secondaryContainer: Colors.amber,
                  ),
            ),
            child: Column(
              children: [
                Text(AppLocale.labelDateAndTime.getTranslation(context)),
                const Gap(4),
                Wrap(
                  direction: Axis.horizontal,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              child: SelectorWheel<int>(
                                childCount: DateTime.monthsPerYear,
                                // highlightBorderRadius: 16.0,
                                highlightHeight: 30.0,
                                width: 46,
                                selectedItemIndex: month.value - 1,

                                convertIndexToValue: (int index) {
                                  return SelectorWheelValue<int>(
                                    // The label is what is displayed on the selector wheel
                                    label: DateTime(1, index + 1).format('MMM'),
                                    value: index + 1,
                                    index: index,
                                  );
                                },
                                onValueChanged: (SelectorWheelValue<int> value) {
                                  month.add(value.value);
                                },
                              ),
                            ),
                            const Gap(8),
                            SizedBox(
                              height: 100,
                              child: StreamBuilder(
                                  stream: lastDayOfMonth,
                                  initialData: lastDayOfMonth.value,
                                  builder: (context, snapshot) {
                                    final data = snapshot.data!;
                                    return SelectorWheel<int>(
                                      childCount: data.day,
                                      selectedItemIndex: date.value.day - 1,
                                      highlightHeight: 30.0,
                                      width: 36,
                                      convertIndexToValue: (int index) {
                                        return SelectorWheelValue<int>(
                                          // The label is what is displayed on the selector wheel
                                          label: (index + 1).toString().padLeft(2, '0'),
                                          value: index + 1,
                                          index: index,
                                        );
                                      },
                                      onValueChanged: (SelectorWheelValue<int> value) {
                                        day.add(value.value);
                                      },
                                    );
                                  }),
                            ),
                            const Gap(8),
                            SizedBox(
                              height: 100,
                              child: SelectorWheel<int>(
                                childCount: 9999,
                                highlightHeight: 30.0,
                                width: 46,
                                selectedItemIndex: year.value,
                                convertIndexToValue: (int index) {
                                  return SelectorWheelValue<int>(
                                    // The label is what is displayed on the selector wheel
                                    label: (index + 1).toString(),
                                    value: index + 1,
                                    index: index,
                                  );
                                },
                                onValueChanged: (SelectorWheelValue<int> value) {
                                  year.add(value.value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 100,
                              child: SelectorWheel<int>(
                                childCount: 24,
                                highlightHeight: 30.0,
                                width: 36,
                                selectedItemIndex: hours.value,
                                convertIndexToValue: (int index) {
                                  return SelectorWheelValue<int>(
                                    // The label is what is displayed on the selector wheel
                                    label: index.toString().padLeft(2, '0'),

                                    value: index,
                                    index: index,
                                  );
                                },
                                onValueChanged: (SelectorWheelValue<int> value) {
                                  hours.add(value.value);
                                },
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text(":")),
                            SizedBox(
                              height: 100,
                              child: SelectorWheel<int>(
                                childCount: 60,
                                highlightHeight: 30.0,
                                width: 36,
                                selectedItemIndex: minutes.value,
                                convertIndexToValue: (int index) {
                                  return SelectorWheelValue<int>(
                                    // The label is what is displayed on the selector wheel
                                    label: index.toString().padLeft(2, '0'),

                                    value: index,
                                    index: index,
                                  );
                                },
                                onValueChanged: (SelectorWheelValue<int> value) {
                                  minutes.add(value.value);
                                },
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text(":")),
                            SizedBox(
                              height: 100,
                              child: SelectorWheel<int>(
                                childCount: 60,
                                highlightHeight: 30.0,
                                width: 36,
                                selectedItemIndex: seconds.value,
                                convertIndexToValue: (int index) {
                                  return SelectorWheelValue<int>(
                                    // The label is what is displayed on the selector wheel
                                    label: index.toString().padLeft(2, '0'),
                                    value: index,
                                    index: index,
                                  );
                                },
                                onValueChanged: (SelectorWheelValue<int> value) {
                                  seconds.add(value.value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              final d = date.value;
              context.pop(
                d.copyWith(
                  hour: hours.value,
                  minute: minutes.value,
                  second: seconds.valueOrNull,
                ),
              );
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
