import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selector_wheel/selector_wheel.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';

import '../../../../util/extensions/build_context_extensions.dart';

class CRepsSelector extends StatefulWidget {
  final int data;
  const CRepsSelector({
    super.key,
    required this.data,
  });

  @override
  State<CRepsSelector> createState() => _CRepsSelectorState();
}

class _CRepsSelectorState extends State<CRepsSelector> {
  late final reps = BehaviorSubject.seeded(widget.data);

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
                    child: SelectorWheel<int>(
                      childCount: 999,
                      selectedItemIndex: reps.value - 1,
                      highlightHeight: 40.0,
                      childHeight: 40,
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
            ),
            const Gap(16),
            Center(
              child: IconButton.filled(
                onPressed: () {
                  context.pop(reps.value);
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
