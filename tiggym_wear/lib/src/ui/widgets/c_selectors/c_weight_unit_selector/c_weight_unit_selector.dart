import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CWeightUnitSelector extends StatefulWidget {
  final WeightUnitEnum data;
  const CWeightUnitSelector({
    super.key,
    required this.data,
  });

  @override
  State<CWeightUnitSelector> createState() => _CWeightUnitSelectorState();
}

class _CWeightUnitSelectorState extends State<CWeightUnitSelector> {
  late final weightUnit = BehaviorSubject.seeded(widget.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(16),
            Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(
                      titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20.0,
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
                  SizedBox(
                    height: 80,
                    child: SelectorWheel<WeightUnitEnum>(
                      childCount: WeightUnitEnum.values.length,
                      selectedItemIndex: WeightUnitEnum.values.indexOf(weightUnit.value),
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 46,
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
            ),
            const Gap(16),
            Center(
              child: IconButton.filled(
                onPressed: () {
                  context.pop(weightUnit.value);
                },
                icon: const Icon(Icons.check, size: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
