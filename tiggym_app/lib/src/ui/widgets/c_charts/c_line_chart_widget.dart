import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as path;
import 'package:tiggym_shared/tiggym_shared.dart';

import '../c_zoomable_chart/c_zoomable_chart.dart';

class LineChartModel {
  final List<LineChartItemModel> items;
  final String Function(BuildContext context, int index, int currentSkip, int currentZoom) xAxisLabels;
  final double maxX;
  final double? maxY;
  final double? minMaxY;
  final String Function(num?) valueFormatter;

  LineChartModel({
    required this.items,
    required this.xAxisLabels,
    required this.maxX,
    this.minMaxY,
    this.maxY,
    required this.valueFormatter,
  });

  LineChartModel copyWith({
    List<LineChartItemModel>? items,
    String Function(BuildContext context, int index, int currentSkip, int currentZoom)? xAxisLabels,
    double? maxX,
    ValueGetter<double?>? maxY,
    ValueGetter<double?>? minMaxY,
    String Function(num?)? valueFormatter,
  }) {
    return LineChartModel(
      items: items ?? this.items,
      xAxisLabels: xAxisLabels ?? this.xAxisLabels,
      maxX: maxX ?? this.maxX,
      maxY: maxY != null ? maxY.call() : this.maxY,
      minMaxY: minMaxY != null ? minMaxY.call() : this.minMaxY,
      valueFormatter: valueFormatter ?? this.valueFormatter,
    );
  }

  LineChartModel replaceMaxY() {
    return copyWith(minMaxY: () => items.fold(3.0, (p, e) => max(p ?? 0, e.values.fold(0, (p1, e1) => max(p1, e1.value.toDouble())))));
  }
}

class LineChartItemModel {
  final String label;
  final bool isCurved;
  final List<LineChartItemValueModel> values;
  final Color color;

  LineChartItemModel({
    required this.label,
    required this.values,
    required this.color,
    this.isCurved = false,
  });

  LineChartItemModel copyWith({
    String? label,
    bool? isCurved,
    List<LineChartItemValueModel>? values,
    Color? color,
  }) {
    return LineChartItemModel(
      label: label ?? this.label,
      isCurved: isCurved ?? this.isCurved,
      values: values ?? this.values,
      color: color ?? this.color,
    );
  }
}

class LineChartItemValueModel {
  final num value;
  final String formattedValue;

  LineChartItemValueModel({
    required this.value,
    required this.formattedValue,
  });

  LineChartItemValueModel.fromInt({required this.value}) : formattedValue = value.toInt().toString();

  LineChartItemValueModel.empty()
      : value = 0,
        formattedValue = '';

  LineChartItemValueModel copyWith({
    num? value,
    String? formattedValue,
  }) {
    return LineChartItemValueModel(
      value: value ?? this.value,
      formattedValue: formattedValue ?? this.formattedValue,
    );
  }
}

class CLineChartWidget extends StatefulWidget {
  final LineChartModel data;
  final int maxItems;
  final String? title;
  final double? maxY;
  final double? interval;
  final int initialSkip = 0;
  final int? currentZoom;
  const CLineChartWidget({
    super.key,
    required this.data,
    this.maxItems = 10,
    this.title,
    this.maxY,
    this.interval,
    this.currentZoom,
  });

  @override
  State<CLineChartWidget> createState() => _CLineChartWidgetState();
}

class _CLineChartWidgetState extends State<CLineChartWidget> {
  late int currentSkip = widget.initialSkip;
  late int currentZoom = widget.currentZoom ?? 10;

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
    return Column(
      children: [
        if (widget.title != null) ...[
          Row(
            children: [
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const Gap(16)
        ],
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CHorizontallyScrollableChart(
            onUpdateZoom: (zoom) {
              int currentZoom = this.currentZoom + -(zoom ~/ 5);
              currentZoom = currentZoom > widget.data.maxX.toInt() ? widget.data.maxX.toInt() : currentZoom;
              currentZoom = max(10, currentZoom);
              this.currentZoom = currentZoom;
              setState(() {});
            },
            onUpdateSkip: (skip) {
              double skipCount = min(30, 30 - (currentZoom - 30) / 3);
              skipCount = skipCount < 10 ? 10 : skipCount;
              int currentSkip = this.currentSkip + -(skip ~/ (skipCount));
              currentSkip = currentSkip + currentZoom > widget.data.maxX ? widget.data.maxX.toInt() - currentZoom : currentSkip;
              currentSkip = max(0, currentSkip);
              this.currentSkip = currentSkip;
              setState(() {});
            },
            builder: (skip, zoom) {
              int currentZoom = this.currentZoom + -(zoom ~/ 5);
              currentZoom = currentZoom > widget.data.maxX.toInt() ? widget.data.maxX.toInt() : currentZoom;
              currentZoom = max(10, currentZoom);
              final maxVisibleX = currentZoom;
              double skipCount = min(30, 30 - (currentZoom - 30) / 3);
              skipCount = skipCount < 10 ? 10 : skipCount;

              int currentSkip = this.currentSkip + -(skip ~/ (skipCount));
              currentSkip = currentSkip + maxVisibleX > widget.data.maxX ? widget.data.maxX.toInt() - maxVisibleX : currentSkip;
              currentSkip = max(0, currentSkip);

              return LineChart(
                key: UniqueKey(),
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
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
                        getTitlesWidget: (v, meta) {
                          final index = v + max(0, currentSkip);
                          final i = min(widget.data.maxX, index);
                          return bottomTitleWidgets(i, meta, currentSkip, currentZoom);
                        },
                        reservedSize: 20,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, interval: widget.interval ?? max(widget.data.minMaxY ?? 0, maxValue).getInterval(), getTitlesWidget: leftTitleWidgets, reservedSize: leftSize),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: _getTooltipItems,
                      getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
                      // Todo: alterar
                      // tooltipBgColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  minX: 0,
                  // maxX: maxVisibleX.toDouble(),
                  minY: 0,
                  maxY: widget.maxY ?? max(widget.data.minMaxY ?? 0, maxValue).getMaxNextValue().toDouble(),
                  lineBarsData: List.generate(
                    widget.data.items.length,
                    (index) => LineChartBarData(
                      spots: List.generate(
                        widget.data.items[index].values.getBetween(currentSkip, currentSkip + maxVisibleX).length,
                        (iCol) => FlSpot(
                          iCol.toDouble(),
                          widget.data.items[index].values.getBetween(currentSkip, currentSkip + maxVisibleX).toList()[iCol].value.toDouble(),
                        ),
                      ),
                      isCurved: widget.data.items[index].isCurved,
                      gradient: LinearGradient(
                        colors: [
                          widget.data.items[index].color,
                          widget.data.items[index].color,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            widget.data.items[index].color.withOpacity(0.4),
                            widget.data.items[index].color.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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

  Widget bottomTitleWidgets(double value, TitleMeta meta, int currentSkip, int currentZoom) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Transform.rotate(
        angle: -pi / 4,
        child: Text(widget.data.xAxisLabels.call(context, value.toInt(), currentSkip, currentZoom), style: style),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
      child: Text(
        widget.data.valueFormatter.call(value),
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }
}

class CHorizontallyScrollableChart extends StatefulWidget {
  final double initialSkip = 0;
  final Widget Function(double, double) builder;
  final void Function(double) onUpdateSkip;
  final void Function(double) onUpdateZoom;

  const CHorizontallyScrollableChart({
    super.key,
    required this.builder,
    required this.onUpdateSkip,
    required this.onUpdateZoom,
  });

  @override
  State<CHorizontallyScrollableChart> createState() => _CHorizontallyScrollableChartState();
}

class _CHorizontallyScrollableChartState extends State<CHorizontallyScrollableChart> {
  final Map<int, (Offset, Offset)> pointers = {};
  late double skip = widget.initialSkip;
  late double zoom = 0;
  Offset startPosition = Offset.zero;
  String action = "";

  void onEnd(int pointer) {
    pointers.remove(pointer);

    final newAction = pointers.length == 1
        ? "scroll"
        : pointers.length > 1
            ? "zoom"
            : "";
    if (action == "scroll" && newAction != action) {
      widget.onUpdateSkip.call(skip);
      skip = 0;
    } else if (action == "zoom" && newAction != action) {
      widget.onUpdateZoom.call(zoom);
      zoom = 0;
    }
    // pointers.forEach((key, value) {
    //   pointers[key] = (value.$1, value.$2);
    // });
    action = newAction;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        pointers.addAll({event.pointer: (event.position, event.position)});
      },
      onPointerMove: (event) {
        // final pointers = Map<int, (Offset, Offset)>.from(this.pointers);
        if (pointers.containsKey(event.pointer)) {
          pointers.update(event.pointer, (value) => (pointers[event.pointer]!.$1, event.position));
        }

        if (pointers.length == 1) {
          action = "scroll";
          // Scroll
          final newSkip = (pointers.entries.first.value.$2.dx - pointers.entries.first.value.$1.dx);

          if (newSkip != skip) {
            setState(() {
              skip = newSkip;
            });
          }
        } else if (pointers.length > 1) {
          action = "zoom";
          final newZoom =
              (pointers.entries.first.value.$1.dx - pointers.entries.skip(1).first.value.$1.dx).abs() - (pointers.entries.first.value.$2.dx - pointers.entries.skip(1).first.value.$2.dx).abs();

          if (newZoom != zoom) {
            print("NewZoom $newZoom");
            setState(() {
              zoom = newZoom;
            });
          }
          // Zoom
        }
      },
      onPointerUp: (event) {
        onEnd(event.pointer);
        print("[onPointerUp] ${event.pointer}");
      },
      onPointerCancel: (event) {
        onEnd(event.pointer);
        print("[onPointerCancel] ${event.pointer}");
      },
      child: GestureDetector(
        // onScaleStart: (details) {
        //   print("[onScaleStart] ScaleStart");
        //   startPosition = details.focalPoint;

        //   // details.
        //   // print("[onScaleStart]: ${details.}")
        //   // lastMinXValue = minX;
        //   // lastMaxXValue = maxX;
        // },
        // onScaleUpdate: (details) {
        //   print("[onScaleUpdate] ${details.horizontalScale}");
        //   print("[onScaleUpdate] Horizontal Distance $details");
        // },
        // onHorizontalDragStart: (details) {
        //   startPosition = details.globalPosition;
        //   // lastMinXValue = minX;
        //   // lastMaxXValue = maxX;
        // },
        // onHorizontalDragEnd: (details) {
        //   widget.onUpdateSkip.call(skip);
        //   skip = 0;
        // },
        // onHorizontalDragUpdate: (details) {
        //   var horizontalDistance = details.primaryDelta ?? 0;
        //   print("Horizontal Distance ${details.globalPosition.dx - startPosition.dx}");
        //   final newSkip = (details.globalPosition.dx - startPosition.dx);
        //   if (newSkip != skip) {
        //     setState(() {
        //       skip = newSkip;
        //     });
        //   }
        // },
        child: widget.builder.call(skip, zoom),
      ),
    );
  }
}
