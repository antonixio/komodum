import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../data/repository/exercise_repository/exercise_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_empty_message/c_empty_message_widget.dart';
import '../../widgets/c_tag_item/c_tag_item_widget.dart';
import 'edit_exercise_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final bool isSelection;
  const ExercisesScreen({
    super.key,
    this.isSelection = false,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final exerciseRepository = GetIt.I.get<ExerciseRepository>();
  final search = BehaviorSubject.seeded('');

  late final exercises = Rx.combineLatest2(search, exerciseRepository.data, (a, b) {
    if (a.isNotEmpty) {
      return b.where((element) => element.getName(context).toUpperCase().contains(a.toUpperCase()) || (element.tag?.getName(context) ?? '').toUpperCase().contains(a.toUpperCase())).toList();
    }

    return b;
  }).shareValueSeeded(exerciseRepository.data.value);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            IconButton(
              onPressed: () {
                context.push((context) => const EditExerciseScreen());
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: StreamBuilder(
            stream: exercises,
            initialData: exercises.value,
            builder: (context, snapshot) {
              final data = (snapshot.data ?? <ExerciseModel>[]).where((element) => element.deletedAt == null).toList();
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                children: [
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    onChanged: (v) {
                      search.add(v);
                      // tag.add(tag.value.copyWith(name: v));
                    },
                    decoration: InputDecoration(
                      hintText: AppLocale.labelSearch.getTranslation(context),
                      border: InputBorder.none,
                    ),
                  ),
                  const Gap(16),
                  if (data.isEmpty)
                    CEmptyMessageWidget(
                      title: AppLocale.messageNothingHereYet.getTranslation(context),
                      subtitle: AppLocale.messageOops.getTranslation(context),
                    ),
                  ...data
                      .map<Widget>((e) => CExerciseWidget(
                            exercise: e,
                            isSelection: widget.isSelection,
                          ))
                      .addBetween(const Gap(16))
                      .toList(),
                ],
              );
            }),
      ),
    );
  }
}

class CExerciseWidget extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isSelection;
  const CExerciseWidget({
    super.key,
    required this.exercise,
    this.isSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    final tag = exercise.tag;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isSelection
            ? () {
                context.pop(exercise);
              }
            : () {
                context.push((context) => EditExerciseScreen(exercise: exercise));
              },
        onLongPress: !isSelection
            ? () {
                context.showMaterialModalBottomSheet(
                  (context) => ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    children: [
                      ListTile(
                        dense: true,
                        onTap: () async {
                          context.pop();
                          context.push((context) => EditExerciseScreen(exercise: exercise));
                        },
                        leading: const Icon(Icons.edit, size: 12),
                        title: Text(AppLocale.labelEdit.getTranslation(context)),
                      ),
                      if (!exercise.fromApp)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.delete, size: 12),
                          textColor: Theme.of(context).colorScheme.error,
                          iconColor: Theme.of(context).colorScheme.error,
                          title: Text(AppLocale.labelDelete.getTranslation(context)),
                          onTap: () {
                            context.pop();
                            GetIt.I.get<ExerciseRepository>().delete(exercise.id);
                          },
                        )
                    ],
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.getName(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  tag != null ? CTagItemWidget(tag: tag, backgroundColor: Theme.of(context).colorScheme.surfaceVariant) : const SizedBox(),
                  Text(
                    exercise.type.getLabel(context),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
