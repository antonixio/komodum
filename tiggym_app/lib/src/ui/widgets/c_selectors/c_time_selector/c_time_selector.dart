import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';
import '../c_selector_wheel/c_selector_wheel_widget.dart';

class CTimeSelector extends StatefulWidget {
  final dynamic data;
  const CTimeSelector({
    super.key,
    required this.data,
  });

  @override
  State<CTimeSelector> createState() => _CTimeSelectorState();
}

class _CTimeSelectorState extends State<CTimeSelector> {
  late final hours = BehaviorSubject.seeded((widget.data.duration as Duration).hours);
  late final minutes = BehaviorSubject.seeded((widget.data.duration as Duration).minutes);
  late final seconds = BehaviorSubject.seeded((widget.data.duration as Duration).seconds);
  late final duration = Rx.combineLatest3(hours, minutes, seconds, (a, b, c) => Duration(hours: a, minutes: b, seconds: c)).shareValueSeeded(Duration.zero);

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
                    Text(AppLocale.labelTime.getTranslation(context)),
                    const Gap(4),
                    Row(
                      children: [
                        SizedBox(
                          height: 100,
                          child: CSelectorWheelWidget<int>(
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
                          child: CSelectorWheelWidget<int>(
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
                          child: CSelectorWheelWidget<int>(
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
          StreamBuilder(
              stream: duration,
              initialData: duration.value,
              builder: (context, snapshot) {
                final data = snapshot.data!;
                if (data.inSeconds > 0) return const SizedBox.shrink();
                return Text(
                  AppLocale.labelSelectValidTime.getTranslation(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                );
              }),
          ElevatedButton(
            onPressed: () {
              final dur = duration.value;
              if (dur.inSeconds > 0) {
                context.pop(widget.data.copyWith(duration: dur));
              }
            },
            child: Text(AppLocale.labelSave.getTranslation(context)),
          )
        ],
      );
    });
  }
}
