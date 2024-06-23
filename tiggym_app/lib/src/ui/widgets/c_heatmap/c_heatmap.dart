import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CHeatMap extends StatelessWidget {
  final DateTime? startAt;
  final DateTime? endAt;
  final Map<DateTime, int>? datasets;
  late final Map<int, Color> colorsets;
  final Color defaultColor;

  CHeatMap({
    super.key,
    this.startAt,
    this.endAt,
    this.datasets,
    required Map<int, Color> colorsets,
    required this.defaultColor,
  }) {
    this.colorsets = Map.fromEntries(colorsets.entries.toList()..sort((a, b) => -(a.key.compareTo(b.key))));
  }

  @override
  Widget build(BuildContext context) {
    final initialDate = (startAt?.dateOnly ?? DateTime.now().dateOnly.copyWith(year: DateTime.now().year - 1));
    // final initialDate = (startAt ?? DateTime.now().copyWith(year: 2023)).mostRecentSunday;
    final finalDate = endAt ?? DateTime.now().toUtc();
    const startWeekday = 7;
    final dates = initialDate.mostRecentWeekday(startWeekday).getDaysUntil(end: finalDate.mostRecentWeekday(startWeekday).lastDayOfWeek);
    final weekdaysDates = Map.fromEntries(List.generate(DateTime.daysPerWeek, (i) => MapEntry(i + 1, dates.where((element) => element.weekday == i + 1).toList())));

    final maxColumns = weekdaysDates.entries.map((e) => e.value.length).fold(0, max);

    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 1,2,3,4,5,6,7
          // 4,5,6,7,1,2,3,4,5,6,7,1,2,3,4
          Column(
            children: List.generate(weekdaysDates.entries.length, (index) {
              final weekday = weekdaysDates.entries.getCircular(index + startWeekday - 1).key; // (index + startWeekday) % DateTime.daysPerWeek + 1;
              return Row(
                children: List.generate(
                  maxColumns,
                  (index) {
                    final date = weekdaysDates[weekday]?.elementAtOrNull(index);
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: date?.dateOnly.isBetween(initialDate, finalDate) ?? false ? getColor(date) : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        width: 10,
                        height: 10,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color getColor(DateTime? date) {
    final dataset = datasets?[date?.dateOnly];
    Color color = defaultColor;
    for (var entry in colorsets.entries) {
      if (entry.key <= (dataset ?? 0)) {
        color = entry.value;
        break;
      }
    }
    return color;
  }
}
