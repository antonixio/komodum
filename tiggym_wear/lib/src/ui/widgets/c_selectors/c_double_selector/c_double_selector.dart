import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../../data/model/weight_model.dart';
import '../../../../util/extensions/build_context_extensions.dart';

class CDoubleSelector extends StatefulWidget {
  final double data;
  final int startInt;
  final int count;
  final String Function(double)? validate;
  const CDoubleSelector({
    super.key,
    required this.data,
    this.startInt = 1,
    this.count = 999,
    this.validate,
  });

  @override
  State<CDoubleSelector> createState() => _CDoubleSelectorState();
}

class _CDoubleSelectorState extends State<CDoubleSelector> {
  late final doubleInt = BehaviorSubject.seeded(widget.data.toInt());
  late final doubleDecimal = BehaviorSubject.seeded(((widget.data - widget.data.floor()) * 10).toInt());
  late final finalValue = Rx.combineLatest2(doubleInt, doubleDecimal, (a, b) => a + (b / 10)).shareValueSeeded(doubleInt.value + (doubleDecimal.value / 10));

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
                      // secondaryContainer: Colors.amber,
                    ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    child: SelectorWheel<int>(
                      childCount: widget.count,
                      selectedItemIndex: doubleInt.value - widget.startInt,
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 46,
                      convertIndexToValue: (int index) {
                        return SelectorWheelValue<int>(
                          // The label is what is displayed on the selector wheel
                          label: (index + widget.startInt).toString(),
                          value: index + widget.startInt,
                          index: index,
                        );
                      },
                      onValueChanged: (SelectorWheelValue<int> value) {
                        doubleInt.add(value.value);
                      },
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text(".")),
                  SizedBox(
                    height: 80,
                    child: SelectorWheel<int>(
                      childCount: 10,
                      selectedItemIndex: doubleDecimal.value - 1,
                      highlightHeight: 40.0,
                      childHeight: 40,
                      width: 46,
                      convertIndexToValue: (int index) {
                        return SelectorWheelValue<int>(
                          // The label is what is displayed on the selector wheel
                          label: (index).toString(),
                          value: index,
                          index: index,
                        );
                      },
                      onValueChanged: (SelectorWheelValue<int> value) {
                        doubleDecimal.add(value.value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder(
                stream: finalValue,
                initialData: finalValue.value,
                builder: (context, snapshot) {
                  final data = snapshot.data!;
                  if (widget.validate == null) return const SizedBox.shrink();
                  final text = widget.validate?.call(data) ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: text.isEmpty ? Colors.transparent : Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
            Center(
              child: IconButton.filled(
                onPressed: () {
                  final value = doubleInt.value + (doubleDecimal.value / 10);
                  if ((widget.validate?.call(value) ?? '').isEmpty) {
                    context.pop(value);
                  }
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
