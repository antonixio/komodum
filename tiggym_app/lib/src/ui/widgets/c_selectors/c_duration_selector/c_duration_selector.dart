import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CDurationSelector extends StatefulWidget {
  final Duration data;
  const CDurationSelector({
    super.key,
    required this.data,
  });

  @override
  State<CDurationSelector> createState() => _CDurationSelectorState();
}

class _CDurationSelectorState extends State<CDurationSelector> {
  late final hours = BehaviorSubject.seeded(widget.data.hours);
  late final minutes = BehaviorSubject.seeded(widget.data.minutes);
  late final seconds = BehaviorSubject.seeded(widget.data.seconds);

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
                    Text(AppLocale.labelDuration.getTranslation(context)),
                    const Gap(4),
                    Row(
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
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              final dur = Duration(
                seconds: seconds.value,
                minutes: minutes.value,
                hours: hours.value,
              );
              context.pop(dur);
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
