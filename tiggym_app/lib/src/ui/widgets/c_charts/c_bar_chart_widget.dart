import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class BarChartModel {
  final List<BarChartItemModel> items;
  final List<String> xAxisLabels;
  final String Function(num?) valueFormatter;

  BarChartModel({
    required this.items,
    required this.xAxisLabels,
    required this.valueFormatter,
  });
}

class BarChartItemModel {
  final String label;
  final bool isCurved;
  final List<BarChartItemValueModel> values;
  final Color color;

  BarChartItemModel({
    required this.label,
    required this.values,
    required this.color,
    this.isCurved = false,
  });
}

class BarChartItemValueModel {
  final num value;
  final String formattedValue;

  BarChartItemValueModel({
    required this.value,
    required this.formattedValue,
  });

  BarChartItemValueModel.fromInt({required this.value}) : formattedValue = value.toInt().toString();

  BarChartItemValueModel.empty()
      : value = 0,
        formattedValue = '';
}

class CBarChartWidget extends StatefulWidget {
  final BarChartModel data;
  final int maxItems;
  final String? title;
  final double? maxY;
  final double? interval;
  const CBarChartWidget({
    super.key,
    required this.data,
    this.maxItems = 10,
    this.title,
    this.maxY,
    this.interval,
  });

  @override
  State<CBarChartWidget> createState() => _CBarChartWidgetState();
}

class _CBarChartWidgetState extends State<CBarChartWidget> {
  @override
  void initState() {
    super.initState();
  }

  double get maxValue => widget.data.items.fold(0.0, (p1, e1) => max(p1, e1.values.fold(0.0, (p2, e2) => max(p2.toDouble(), e2.value.toDouble()))));

  @override
  Widget build(BuildContext context) {
    final leftSize = (TextPainter(
                text: TextSpan(
                    text: widget.data.valueFormatter.call(widget.maxY ?? maxValue.getMaxNextValue()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    )),
                maxLines: 1,
                textDirection: TextDirection.ltr)
              ..layout())
            .size
            .width +
        16;

    // final bottomSize = (TextPainter(
    //             text: TextSpan(
    //                 text: widget.data.xAxisLabels.fold("", (p, c) => (p ?? '').length > c.length ? p : c),
    //                 style: const TextStyle(
    //                   fontWeight: FontWeight.bold,
    //                   fontSize: 12,
    //                 )),
    //             maxLines: 1,
    //             textDirection: TextDirection.ltr)
    //           ..layout())
    //         .size
    //         .width +
    //     20;
    // final width = MediaQuery.sizeOf(context).width - 64;
    // final widthMinusLeftsize = width - leftSize;
    // final itemSpace = widthMinusLeftsize / widget.data.xAxisLabels.length;
    return Column(
      children: [
        if (widget.title != null) ...[
          Row(
            children: [
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const Gap(16)
        ],
        const Gap(8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Colors.transparent,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(
                    color: Colors.transparent,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: bottomTitleWidgets,
                    reservedSize: 20,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: widget.interval ?? maxValue.getInterval(), getTitlesWidget: leftTitleWidgets, reservedSize: leftSize),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(
                    color: Color(0xff37434d),
                  ),
                  bottom: BorderSide(
                    color: Color(0xff37434d),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 8,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ) ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                    );
                  },
                ),
              ),
              minY: 0,
              maxY: widget.maxY ?? maxValue.getMaxNextValue().toDouble(),
              barGroups: List.generate(
                widget.data.items.length,
                (index) => BarChartGroupData(
                  x: index,
                  showingTooltipIndicators: [0],
                  barRods: List.generate(
                    widget.data.items[index].values.length,
                    (iCol) => BarChartRodData(
                      toY: widget.data.items[index].values[iCol].value.toDouble(),
                      color: widget.data.items[index].color,
                    ),
                  ),
                  // isCurved: widget.data.items[index].isCurved,
                  // gradient: LinearGradient(
                  //   colors: [
                  //     widget.data.items[index].color,
                  //     widget.data.items[index].color,
                  //   ],
                  // ),
                  // barWidth: 3,
                  // isStrokeCapRound: true,
                  // dotData: const FlDotData(
                  //   show: false,
                  // ),
                  // belowBarData: BarAreaData(
                  //   show: true,
                  //   gradient: LinearGradient(
                  //     colors: [
                  //       widget.data.items[index].color.withOpacity(0.1),
                  //       widget.data.items[index].color.withOpacity(0.01),
                  //     ],
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
        ),
        const Gap(16),
      ],
    );
  }

  List<LineTooltipItem> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final textStyle = TextStyle(
        color: touchedSpot.bar.gradient?.colors.first ?? touchedSpot.bar.color ?? Colors.blueGrey,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      return LineTooltipItem(
        widget.data.valueFormatter.call(touchedSpot.y),
        textStyle,
      );
    }).toList();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(widget.data.xAxisLabels.elementAtOrNull(value.toInt()) ?? '', style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(widget.data.valueFormatter.call(value), style: style, textAlign: TextAlign.right),
    );
  }
}
