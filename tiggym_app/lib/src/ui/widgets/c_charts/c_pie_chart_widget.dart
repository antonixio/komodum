import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CPieChartSectionData extends PieChartSectionData {
  final String? label;

  CPieChartSectionData({
    super.value,
    super.color,
    super.gradient,
    super.radius,
    super.showTitle,
    super.titleStyle,
    super.title,
    super.borderSide,
    super.badgeWidget,
    super.titlePositionPercentageOffset,
    super.badgePositionPercentageOffset,
    required this.label,
  });

  @override
  CPieChartSectionData copyWith(
      {double? value,
      Color? color,
      Gradient? gradient,
      double? radius,
      bool? showTitle,
      TextStyle? titleStyle,
      String? title,
      BorderSide? borderSide,
      Widget? badgeWidget,
      double? titlePositionPercentageOffset,
      double? badgePositionPercentageOffset,
      String? label}) {
    return CPieChartSectionData(
      value: value ?? this.value,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      radius: radius ?? this.radius,
      showTitle: showTitle ?? this.showTitle,
      titleStyle: titleStyle ?? this.titleStyle,
      title: title ?? this.title,
      borderSide: borderSide ?? this.borderSide,
      badgeWidget: badgeWidget ?? this.badgeWidget,
      titlePositionPercentageOffset: titlePositionPercentageOffset ?? this.titlePositionPercentageOffset,
      badgePositionPercentageOffset: badgePositionPercentageOffset ?? this.badgePositionPercentageOffset,
      label: label ?? this.label,
    );
  }
}

class CPieChartWidget extends StatefulWidget {
  final List<CPieChartSectionData> dataset;
  final int maxItems;
  final String? title;
  final bool sort;
  const CPieChartWidget({
    super.key,
    required this.dataset,
    this.maxItems = 10,
    this.title,
    this.sort = false,
  });

  @override
  State<CPieChartWidget> createState() => _CPieChartWidgetState();
}

class _CPieChartWidgetState extends State<CPieChartWidget> {
  late List<CPieChartSectionData> dataset;
  late List<CPieChartSectionData> take;
  late List<CPieChartSectionData> remaining;
  CPieChartSectionData? remainigSection;
  CPieChartSectionData? touched;

  List<CPieChartSectionData> get datasetFiltered => dataset.where((element) => element.value > 0).toList();

  @override
  void initState() {
    final d = [...widget.dataset];

    // for (var i = 0; i < 13; i++) {
    //   d.addAll(List.generate(
    //     widget.dataset.length,
    //     (index) => widget.dataset[index].copyWith(),
    //   ));
    // }

    if (widget.sort) {
      d.sort((a, b) => -a.value.compareTo(b.value));
    }

    dataset = List.generate(
      d.length,
      (index) => d[index].copyWith(
        color: d[index].color.withOpacity(0.6),
      ),
    );

    if (datasetFiltered.length > widget.maxItems) {
      take = datasetFiltered.take(widget.maxItems - 1).toList();
      remaining = dataset.where((element) => !take.contains(element)).toList();
      final remainigSection = CPieChartSectionData(color: Colors.grey, value: remaining.fold(0.0, (p, c) => (p ?? 0) + c.value), title: _getRemainingTitle(take, remaining), label: '');
      dataset = [...take, remainigSection];
      this.remainigSection = remainigSection;
    } else {
      take = datasetFiltered;
      remaining = dataset.where((element) => !datasetFiltered.contains(element)).toList();
    }

    if (dataset.every((element) => element.value <= 0)) {
      dataset.add(CPieChartSectionData(title: "", label: "", value: 1, color: Colors.grey));
    }

    super.initState();
  }

  String _getRemainingTitle(List<CPieChartSectionData> take, List<CPieChartSectionData> remaining) {
    final takeValue = take.fold(0.0, (p, c) => p + c.value);
    final remainingValue = remaining.fold(0.0, (p, c) => p + c.value);

    return '${(remainingValue / (remainingValue + takeValue) * 100).toStringAsFixed(1)}%';
  }

  List<CPieChartSectionData> _getSections() {
    double size = (MediaQuery.sizeOf(context).width - 30) / 2;
    size = size > 140 ? 140 : size;
    final list = List.generate(dataset.length, (i) {
      final isTouched = dataset[i] == touched;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? size : size - 10;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return dataset[i].copyWith(
        radius: radius,
        color: dataset[i].color.withOpacity(isTouched ? 1 : 0.8),
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: shadows,
        ),
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null || (pieTouchResponse.touchedSection?.touchedSectionIndex ?? -1) < 0) {
                      touched = null;
                      return;
                    }
                    touched = datasetFiltered[pieTouchResponse.touchedSection!.touchedSectionIndex];
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 1,
              centerSpaceRadius: 0,
              startDegreeOffset: 0,
              sections: _getSections(),
            ),
          ),
        ),
        const Gap(8),
        ...take.map((e) {
          return _indicator(
            size: 12,
            color: e.color,
            text: e.label ?? '',
            isSquare: true,
            isTouched: touched == e,
          );
        }),

        ...remaining.map((e) {
          return _indicator(
            size: 12,
            color: Colors.grey,
            text: e.label ?? '',
            isSquare: true,
            isTouched: touched == remainigSection && remainigSection != null,
          );
        }),
        // ...take.map(
        //   (e) => _indicator(
        //     color: e.color,
        //     text: e.label ?? '',
        //     isSquare: true,
        //     size: 12,
        //     isTouched: touched == e,
        //   ),
        // ),
        // ...remaining.map(
        //   (e) => _indicator(
        //     color: Colors.grey,
        //     text: e.label ?? '',
        //     isSquare: true,
        //     size: 12,
        //     isTouched: touched == remainigSection,
        //   ),
        // ),
      ],
    );
  }

  Widget _indicator({
    required double size,
    bool isSquare = true,
    required Color color,
    required String text,
    bool isTouched = false,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isTouched ? 1.03 : 1,
      child: Row(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color.withOpacity(isTouched ? 1 : 0.8),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
