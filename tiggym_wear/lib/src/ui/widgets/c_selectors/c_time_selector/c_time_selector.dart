import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CTimeSelector extends StatefulWidget {
  final Duration data;
  const CTimeSelector({
    super.key,
    required this.data,
  });

  @override
  State<CTimeSelector> createState() => _CTimeSelectorState();
}

class _CTimeSelectorState extends State<CTimeSelector> {
  late final hours = BehaviorSubject.seeded((widget.data).hours);
  late final minutes = BehaviorSubject.seeded((widget.data).minutes);
  late final seconds = BehaviorSubject.seeded((widget.data).seconds);
  late final duration = Rx.combineLatest3(hours, minutes, seconds, (a, b, c) => Duration(hours: a, minutes: b, seconds: c)).shareValueSeeded(Duration.zero);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
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
                    ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    child: SelectorWheel<int>(
                      childCount: 24,
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 40,
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
                    height: 80,
                    child: SelectorWheel<int>(
                      childCount: 60,
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 40,
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
                    height: 80,
                    child: SelectorWheel<int>(
                      childCount: 60,
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 40,
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
            ),
            const Gap(16),
            StreamBuilder(
                stream: duration,
                initialData: duration.value,
                builder: (context, snapshot) {
                  final data = snapshot.data!;
                  // if (data.inSeconds > 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      AppLocale.labelSelectValidTime.getTranslation(context),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: data.inSeconds > 0 ? Colors.transparent : Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
            Center(
              child: IconButton.filled(
                onPressed: () {
                  final dur = duration.value;
                  if (dur.inSeconds > 0) {
                    context.pop(dur);
                  }
                },
                icon: const Icon(Icons.check, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
