import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CDistanceSelector extends StatefulWidget {
  final dynamic data;
  const CDistanceSelector({
    super.key,
    required this.data,
  });

  @override
  State<CDistanceSelector> createState() => _CDistanceSelectorState();
}

class _CDistanceSelectorState extends State<CDistanceSelector> {
  late final distanceInt = BehaviorSubject.seeded(widget.data.distance.toInt());
  late final distanceDecimal = BehaviorSubject.seeded(((widget.data.distance - widget.data.distance.floor()) * 10).toInt());
  late final distanceUnit = BehaviorSubject.seeded(widget.data.unit);
  late final distance = Rx.combineLatest2(distanceInt, distanceDecimal, (a, b) => a + (b / 10)).shareValueSeeded(widget.data.distance);

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(AppLocale.labelDistance.getTranslation(context)),
                    const Gap(4),
                    Row(
                      children: [
                        SizedBox(
                          height: 100,
                          child: SelectorWheel<int>(
                            childCount: 1000,
                            highlightHeight: 30.0,
                            width: 46,
                            selectedItemIndex: distanceInt.value,
                            convertIndexToValue: (int index) {
                              return SelectorWheelValue<int>(
                                // The label is what is displayed on the selector wheel
                                label: index.toString(),
                                value: index,
                                index: index,
                              );
                            },
                            onValueChanged: (SelectorWheelValue<int> value) {
                              distanceInt.add(value.value);
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text(".")),
                        SizedBox(
                          height: 100,
                          child: SelectorWheel<int>(
                            childCount: 10,
                            highlightHeight: 30.0,
                            width: 36,
                            selectedItemIndex: distanceDecimal.value,
                            convertIndexToValue: (int index) {
                              return SelectorWheelValue<int>(
                                // The label is what is displayed on the selector wheel
                                label: index.toString(),
                                value: index,
                                index: index,
                              );
                            },
                            onValueChanged: (SelectorWheelValue<int> value) {
                              distanceDecimal.add(value.value);
                            },
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          height: 100,
                          child: SelectorWheel<DistanceUnitEnum>(
                            childCount: DistanceUnitEnum.values.length,
                            highlightHeight: 30.0,
                            width: 36,
                            selectedItemIndex: DistanceUnitEnum.values.indexOf(distanceUnit.value),
                            convertIndexToValue: (int index) {
                              return SelectorWheelValue<DistanceUnitEnum>(
                                // The label is what is displayed on the selector wheel
                                label: DistanceUnitEnum.values.elementAt(index).getLabelShort(context),
                                value: DistanceUnitEnum.values.elementAt(index),
                                index: index,
                              );
                            },
                            onValueChanged: (SelectorWheelValue<DistanceUnitEnum> value) {
                              distanceUnit.add(value.value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),
          StreamBuilder(
              stream: distance,
              initialData: distance.value,
              builder: (context, snapshot) {
                final data = snapshot.data!;
                if (data > 0) return const SizedBox.shrink();
                return Text(
                  AppLocale.labelSelectValidDistance.getTranslation(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                );
              }),
          ElevatedButton(
            onPressed: () {
              final dis = distance.value;
              if (dis > 0) {
                context.pop(widget.data.copyWith(distance: dis, unit: distanceUnit.value));
              }
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
