import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CRepsAndWeightSelector extends StatefulWidget {
  final dynamic data;
  const CRepsAndWeightSelector({
    super.key,
    required this.data,
  });

  @override
  State<CRepsAndWeightSelector> createState() => _CRepsAndWeightSelectorState();
}

class _CRepsAndWeightSelectorState extends State<CRepsAndWeightSelector> {
  late final reps = BehaviorSubject.seeded(widget.data.reps);
  late final weightInt = BehaviorSubject.seeded(widget.data.weight.toInt());
  late final weightDecimal = BehaviorSubject.seeded(((widget.data.weight - widget.data.weight.floor()) * 10).toInt());
  late final weightUnit = BehaviorSubject.seeded(widget.data.weightUnit);

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
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(AppLocale.labelReps.getTranslation(context)),
                      const Gap(4),
                      SizedBox(
                        height: 100,
                        child: SelectorWheel<int>(
                          childCount: 999,
                          highlightHeight: 30.0,
                          width: 46,
                          selectedItemIndex: reps.value! - 1,
                          convertIndexToValue: (int index) {
                            return SelectorWheelValue<int>(
                              // The label is what is displayed on the selector wheel
                              label: (index + 1).toString(),
                              value: index + 1,
                              index: index,
                            );
                          },
                          onValueChanged: (SelectorWheelValue<int> value) {
                            reps.add(value.value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Column(
                    children: [
                      const Text(""),
                      const Gap(4),
                      Expanded(
                        child: Container(
                          width: 4,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Column(
                    children: [
                      Text(AppLocale.labelWeight.getTranslation(context)),
                      const Gap(4),
                      Row(
                        children: [
                          SizedBox(
                            height: 100,
                            child: SelectorWheel<int>(
                              childCount: 999,
                              highlightHeight: 30.0,
                              width: 46,
                              selectedItemIndex: weightInt.value! - 1,
                              convertIndexToValue: (int index) {
                                return SelectorWheelValue<int>(
                                  // The label is what is displayed on the selector wheel
                                  label: (index + 1).toString(),
                                  value: index + 1,
                                  index: index,
                                );
                              },
                              onValueChanged: (SelectorWheelValue<int> value) {
                                weightInt.add(value.value);
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
                              selectedItemIndex: weightDecimal.value,
                              convertIndexToValue: (int index) {
                                return SelectorWheelValue<int>(
                                  // The label is what is displayed on the selector wheel
                                  label: index.toString(),
                                  value: index,
                                  index: index,
                                );
                              },
                              onValueChanged: (SelectorWheelValue<int> value) {
                                weightDecimal.add(value.value);
                              },
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            height: 100,
                            child: SelectorWheel<WeightUnitEnum>(
                              childCount: WeightUnitEnum.values.length,
                              highlightHeight: 30.0,
                              width: 36,
                              selectedItemIndex: WeightUnitEnum.values.indexOf(weightUnit.value),
                              convertIndexToValue: (int index) {
                                return SelectorWheelValue<WeightUnitEnum>(
                                  // The label is what is displayed on the selector wheel
                                  label: WeightUnitEnum.values.elementAt(index).getLabel(context),
                                  value: WeightUnitEnum.values.elementAt(index),
                                  index: index,
                                );
                              },
                              onValueChanged: (SelectorWheelValue<WeightUnitEnum> value) {
                                weightUnit.add(value.value);
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
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              context.pop(widget.data.copyWith(reps: reps.value, weight: weightInt.value + (weightDecimal.value / 10), weightUnit: weightUnit.value));
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
