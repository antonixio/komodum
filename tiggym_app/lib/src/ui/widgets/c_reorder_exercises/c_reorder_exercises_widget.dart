import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/extensions/build_context_extensions.dart';

class CReorderExercisesWidget<T extends OrderableModel<T>> extends StatefulWidget {
  final List<T> exercises;
  const CReorderExercisesWidget({
    super.key,
    required this.exercises,
  });

  @override
  State<CReorderExercisesWidget> createState() => _CReorderExercisesWidgetState<T>();
}

class _CReorderExercisesWidgetState<T extends OrderableModel<T>> extends State<CReorderExercisesWidget<T>> {
  late final exercises = BehaviorSubject<List<T>>.seeded(widget.exercises);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: StreamBuilder(
          stream: exercises,
          initialData: exercises.value,
          builder: (context, snapshot) {
            final data = snapshot.data!;
            return ReorderableListView(
              shrinkWrap: true,
              header: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text(AppLocale.labelReorder.getTranslation(context))),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            context.pop(exercises.value);
                          },
                          icon: const Icon(
                            Icons.check,
                            size: 16,
                          )),
                    ),
                  ],
                ),
              ),
              onReorder: onReorder,
              children: data.map((e) => _buildItem(e)).toList(),
            );
          }),
    );
  }

  void onReorder(oldIndex, newIndex) {
    final exercises0 = [...exercises.value];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = exercises0.removeAt(oldIndex);
    exercises0.insert(newIndex, item);
    final ordered = List.generate(exercises0.length, (index) => exercises0.elementAt(index).copyWithOrder(index + 1))..sort((a, b) => a.order.compareTo(b.order));
    exercises.add(ordered);
  }

  Widget _buildItem(dynamic item) {
    if (item is ExerciseGroupTrainingSessionModel) {
      return _buildItemSession(item);
    }

    if (item is ExerciseGroupTrainingTemplateModel) {
      return _buildItemTemplate(item);
    }

    return const SizedBox();
  }

  Widget _buildItemSession(ExerciseGroupTrainingSessionModel session) {
    return ListTile(
      dense: true,
      leading: Text(session.order.toString()),
      trailing: ReorderableDragStartListener(index: session.order - 1, child: const Icon(Icons.drag_handle)), //Wrap it inside drag start event listener
      key: Key(session.order.toString()),
      title: Text(session.groupType == ExerciseGroupTypeEnum.unique ? (session.exercises.firstOrNull?.exercise.getName(context) ?? '') : AppLocale.labelCompound.getTranslation(context)),
    );
  }

  Widget _buildItemTemplate(ExerciseGroupTrainingTemplateModel template) {
    return ListTile(
      dense: true,

      leading: Text(template.order.toString()),
      trailing: ReorderableDragStartListener(index: template.order - 1, child: const Icon(Icons.drag_handle)), //Wrap it inside drag start event listener
      key: Key(template.order.toString()),
      title: Text(template.groupType == ExerciseGroupTypeEnum.unique ? (template.exercises.firstOrNull?.exercise.getName(context) ?? '') : AppLocale.labelCompound.getTranslation(context)),
    );
  }
}
