import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CRepsSelector extends StatefulWidget {
  final dynamic data;
  const CRepsSelector({
    super.key,
    required this.data,
  });

  @override
  State<CRepsSelector> createState() => _CRepsSelectorState();
}

class _CRepsSelectorState extends State<CRepsSelector> {
  late final reps = BehaviorSubject.seeded(widget.data.reps);

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
                    Text(AppLocale.labelReps.getTranslation(context)),
                    const Gap(4),
                    SizedBox(
                      height: 100,
                      child: SelectorWheel<int>(
                        childCount: 999,
                        selectedItemIndex: reps.value - 1,
                        highlightHeight: 30.0,
                        width: 46,
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
              ],
            ),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              context.pop(widget.data.copyWith(reps: reps.value));
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
