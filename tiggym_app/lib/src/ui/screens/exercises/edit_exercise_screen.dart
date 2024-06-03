import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../data/repository/exercise_repository/exercise_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_exercises/c_exercises_templates/c_unique_exercise_group_widget.dart';
import '../../widgets/c_tag_item/c_tag_item_widget.dart';
import '../tags/tags_screen.dart';

class EditExerciseScreen extends StatefulWidget {
  final ExerciseModel? exercise;
  const EditExerciseScreen({
    super.key,
    this.exercise,
  });

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final exerciseRepository = GetIt.I.get<ExerciseRepository>();

  late final exercise = BehaviorSubject.seeded(widget.exercise ?? ExerciseModel.dummy);
  final GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            if (!exercise.value.fromApp)
              IconButton(
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    if (exercise.value.id <= 0) {
                      exerciseRepository.insert(exercise.value);
                      context.pop();
                    } else {
                      exerciseRepository.update(exercise.value, exercise.value.id);
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.check),
              )
          ],
        ),
        body: StreamBuilder(
            stream: exercise,
            initialData: exercise.value,
            builder: (context, snapshot) {
              final data = snapshot.data!;
              return Form(
                key: key,
                child: ListView(
                  padding: const EdgeInsets.all(32),
                  children: [
                    if (exercise.value.fromApp)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                AppLocale.messageDefaultExercise.getTranslation(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      readOnly: exercise.value.fromApp,
                      initialValue: data.getName(context),
                      onChanged: (v) {
                        exercise.add(exercise.value.copyWith(name: v));
                      },
                      validator: (v) {
                        if (exercise.value.name.trim().isEmpty) {
                          return AppLocale.labelRequired.getTranslation(context);
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocale.labelName.getTranslation(context),
                        border: InputBorder.none,
                      ),
                    ),
                    const Gap(8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FormField(
                        validator: (value) {
                          final tag = exercise.value.tag;
                          if (tag == null || tag.id <= 0) {
                            return AppLocale.labelRequired.getTranslation(context);
                          }
                          return null;
                        },
                        builder: (state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            exercise.value.fromApp
                                ? CTagItemWidget(tag: data.tag ?? TagModel.tagNone)
                                : CTagItemTappableWidget(
                                    tag: data.tag ?? TagModel.tagNone,
                                    onTap: () async {
                                      final tag = await context.push((context) => const TagsScreen(isSelection: true));
                                      if (tag != null && tag is TagModel) {
                                        exercise.add(exercise.value.copyWith(tag: tag));
                                      }
                                    },
                                  ),
                            if (state.hasError)
                              Text(
                                state.errorText ?? "",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              )
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: exercise.value.id > 0
                            ? null
                            : () {
                                context.showMaterialModalBottomSheet(
                                  (_) => ListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(0),
                                    children: ExerciseTypeEnum.values
                                        .map(
                                          (e) => ListTile(
                                            dense: true,
                                            onTap: () {
                                              context.pop();
                                              exercise.add(exercise.value.copyWith(type: e));
                                            },
                                            title: Text(
                                              e.getLabel(context),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                );
                              },
                        child: Row(
                          children: [
                            Text(
                              data.type.getLabel(context),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(exercise.value.id > 0 ? 0.6 : 1)),
                            ),
                            if (exercise.value.id < 0) const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    ),
                    const Gap(32),
                    Center(child: Text(AppLocale.labelPreview.getTranslation(context))),
                    const Gap(8),
                    CUniqueExerciseTemplateGroupWidget(
                      exerciseGroup: ExerciseGroupTrainingTemplateModel.uniqueFromExercise(
                        exercise: data,
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
