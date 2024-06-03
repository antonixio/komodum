import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/extensions/build_context_extensions.dart';

class CReorderSetsCompoundWidget extends StatefulWidget {
  final dynamic exerciseGroup;
  const CReorderSetsCompoundWidget({
    super.key,
    required this.exerciseGroup,
  });

  @override
  State<CReorderSetsCompoundWidget> createState() => _CReorderSetsCompoundWidgetState();
}

class _CReorderSetsCompoundWidgetState extends State<CReorderSetsCompoundWidget> {
  late final exerciseGroup = BehaviorSubject<dynamic>.seeded(widget.exerciseGroup);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: StreamBuilder(
          stream: exerciseGroup,
          initialData: exerciseGroup.value,
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
                            context.pop(exerciseGroup.value);
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
              children: _children(),
            );
          }),
    );
  }

  List<Widget> _children() {
    final exerciseGroup0 = exerciseGroup.value;

    if (exerciseGroup0 is ExerciseGroupTrainingTemplateModel) {
      return _childrenTemplate(exerciseGroup0);
    }

    if (exerciseGroup0 is ExerciseGroupTrainingSessionModel) {
      return _childrenSession(exerciseGroup0);
    }

    return [];
  }

  List<Widget> _childrenTemplate(ExerciseGroupTrainingTemplateModel exerciseGroup0) {
    return List.generate(exerciseGroup0.exercises.firstOrNull?.groupSets.length ?? 0, (index) {
      return ListTile(
        dense: true,
        leading: Text((index + 1).toString()),
        subtitleTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              fontSize: 10,
            ),
        title: Text(AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', (index + 1).toString())),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: exerciseGroup0.exercises
              .map((e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.exercise.getName(context)),
                      ...e.groupSets.elementAt(index).sets.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "${e.order}. ${e.meta.getFormatted(context)}",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ),
                    ],
                  ))
              .toList(),
        ),
        trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)), //Wrap it inside drag start event listener
        key: Key((index + 1).toString()),
      );
    });
  }

  List<Widget> _childrenSession(ExerciseGroupTrainingSessionModel exerciseGroup0) {
    return List.generate(exerciseGroup0.exercises.firstOrNull?.groupSets.length ?? 0, (index) {
      return ListTile(
        dense: true,
        leading: Text((index + 1).toString()),
        subtitleTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              fontSize: 10,
            ),
        title: Text(AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', (index + 1).toString())),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: exerciseGroup0.exercises
              .map((e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.exercise.getName(context)),
                      ...e.groupSets.elementAt(index).sets.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "${e.order}. ${e.meta.getFormatted(context)}",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ),
                    ],
                  ))
              .toList(),
        ),
        trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)), //Wrap it inside drag start event listener
        key: Key((index + 1).toString()),
      );
    });
  }

  void onReorder(oldIndex, newIndex) {
    final exerciseGroup0 = exerciseGroup.value;
    if (exerciseGroup0 is ExerciseGroupTrainingTemplateModel) {
      onReorderTemplate(oldIndex, newIndex, exerciseGroup0);
    }

    if (exerciseGroup0 is ExerciseGroupTrainingSessionModel) {
      onReorderSession(oldIndex, newIndex, exerciseGroup0);
    }
  }

  void onReorderTemplate(oldIndex, newIndex, ExerciseGroupTrainingTemplateModel exerciseGroup0) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exercises0 = [...exerciseGroup0.exercises].map((e) {
      final groupSets = [...e.groupSets];
      final item = groupSets.removeAt(oldIndex);
      groupSets.insert(newIndex, item);
      final ordered = List.generate(groupSets.length, (index) => groupSets.elementAt(index).copyWithOrder(index + 1))..sort((a, b) => a.order.compareTo(b.order));

      return e.copyWith(groupSets: ordered);
    }).toList();
    exerciseGroup.add(exerciseGroup0.copyWith(exercises: exercises0));
  }

  void onReorderSession(oldIndex, newIndex, ExerciseGroupTrainingSessionModel exerciseGroup0) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exercises0 = [...exerciseGroup0.exercises].map((e) {
      final groupSets = [...e.groupSets];
      final item = groupSets.removeAt(oldIndex);
      groupSets.insert(newIndex, item);
      final ordered = List.generate(groupSets.length, (index) => groupSets.elementAt(index).copyWithOrder(index + 1))..sort((a, b) => a.order.compareTo(b.order));

      return e.copyWith(groupSets: ordered);
    }).toList();
    exerciseGroup.add(exerciseGroup0.copyWith(exercises: exercises0));
  }
}
