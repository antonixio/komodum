import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/data/repository/training_session_repository/training_session_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../widgets/c_shareable/c_shareable_widget.dart';

class FinishedWorkoutStatsScreen extends StatefulWidget {
  final int sessionId;
  const FinishedWorkoutStatsScreen({super.key, required this.sessionId});

  @override
  State<FinishedWorkoutStatsScreen> createState() => _FinishedWorkoutStatsScreenState();
}

class _FinishedWorkoutStatsScreenState extends State<FinishedWorkoutStatsScreen> {
  final session = BehaviorSubject.seeded(LoadableDataModel<TrainingSessionModel>.loading());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final sessions = await GetIt.I.get<TrainingSessionRepository>().getTrainings(id: widget.sessionId);
      session.add(LoadableDataModel.success(data: sessions.firstOrNull));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true),
      body: SafeArea(
        child: StreamBuilder(
          stream: session,
          initialData: session.value,
          builder: (context, snapshot) {
            final data = snapshot.data?.data;

            if (data == null) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: CShareableWidget(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              data.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                            const Gap(16),
                            Opacity(
                              opacity: 0.6,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                  ),
                                  const Gap(8),
                                  Text(
                                    data.date.format(AppLocale.formatDateTime.getTranslation(context)),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        // color: Theme.of(context).colorScheme.surfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Opacity(
                              opacity: 0.6,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 16,
                                  ),
                                  const Gap(8),
                                  Text(
                                    data.duration.hoursMinutesSeconds,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        // color: Theme.of(context).colorScheme.surfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            Text(
                              "💪 ${AppLocale.labelExercises.getTranslation(context)}",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    // color: Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                            ),
                            const Gap(8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: data.exercises
                                  .map(
                                    (e) => Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        "- ${e.exercises.map((e) => e.exercise.getName(context)).join(" | ")}",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 0.0),
                            //   child: Column(
                            //     // crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: data.exercises
                            //         .map((e) => e.groupType == ExerciseGroupTypeEnum.unique
                            //             ? Column(
                            //                 // crossAxisAlignment: CrossAxisAlignment.start,
                            //                 children: e.exercises
                            //                     .map(
                            //                       (e) => Material(
                            //                         color: Theme.of(context).colorScheme.surfaceVariant,
                            //                         borderRadius: BorderRadius.circular(12),
                            //                         child: Padding(
                            //                           padding: const EdgeInsets.all(8.0),
                            //                           child: Column(
                            //                             crossAxisAlignment: CrossAxisAlignment.start,
                            //                             children: [
                            //                               Text(
                            //                                 e.exercise.getName(context),
                            //                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            //                               ),
                            //                               ...e.groupSets.map((e) => Padding(
                            //                                     padding: const EdgeInsets.only(left: 8.0),
                            //                                     child: Column(
                            //                                       crossAxisAlignment: CrossAxisAlignment.start,
                            //                                       children: [
                            //                                         Row(
                            //                                           mainAxisSize: MainAxisSize.min,
                            //                                           children: [
                            //                                             Text(
                            //                                               AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', e.order.toString()),
                            //                                               style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            //                                             ),
                            //                                             const Gap(8),
                            //                                           ],
                            //                                         ),
                            //                                         ...e.sets
                            //                                             .map((e) => Row(
                            //                                                   mainAxisSize: MainAxisSize.min,
                            //                                                   children: [
                            //                                                     const Gap(8),
                            //                                                     Icon(
                            //                                                       Icons.check,
                            //                                                       // color: Theme.of(context).colorScheme.primary,
                            //                                                       color: e.done ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            //                                                       size: 12,
                            //                                                     ),
                            //                                                     const Gap(8),
                            //                                                     Text(
                            //                                                       e.meta.getFormatted(context),
                            //                                                       style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            //                                                     ),
                            //                                                   ],
                            //                                                 ))
                            //                                             .toList(),
                            //                                         // ...e.sets
                            //                                         //     .map((e) => Row(
                            //                                         //           mainAxisSize: MainAxisSize.min,
                            //                                         //           children: [
                            //                                         //             const Gap(8),
                            //                                         //             Icon(
                            //                                         //               Icons.check,
                            //                                         //               // color: Theme.of(context).colorScheme.primary,
                            //                                         //               color: e.done ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            //                                         //               size: 12,
                            //                                         //             ),
                            //                                         //             const Gap(8),
                            //                                         //             Text(
                            //                                         //               e.meta.getFormatted(context),
                            //                                         //               style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            //                                         //             ),
                            //                                         //           ],
                            //                                         //         ))
                            //                                         //     .toList(),
                            //                                       ],
                            //                                     ),
                            //                                   ))
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     )
                            //                     .toList(),
                            //               )
                            //             : const Text("A"))
                            //         .toList(),
                            //   ),
                            // ),

                            const Gap(8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(32),
                ...data.exercises
                    .map<Widget>((e) => e.groupType == ExerciseGroupTypeEnum.unique
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: e.exercises
                                  .map(
                                    (e) => Material(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.exercise.getName(context),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            ...e.groupSets.map((e) => Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', e.order.toString()),
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                                          ),
                                                          const Gap(8),
                                                        ],
                                                      ),
                                                      ...e.sets
                                                          .map((e) => Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Gap(8),
                                                                  Icon(
                                                                    Icons.check,
                                                                    // color: Theme.of(context).colorScheme.primary,
                                                                    color: e.done ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                                                    size: 12,
                                                                  ),
                                                                  const Gap(8),
                                                                  Text(
                                                                    e.meta.getFormatted(context),
                                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                                                  ),
                                                                ],
                                                              ))
                                                          .toList(),
                                                    ],
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Material(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    AppLocale.labelCompound.getTranslation(context),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(16),
                                  ...List<Widget>.generate(e.exercises.firstOrNull?.groupSets.length ?? 0, (index) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocale.labelSetN.getTranslation(context).replaceAll('%setnumber%', (index + 1).toString()),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        ...e.exercises.map<Widget>((e) => Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        e.exercise.getName(context),
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                                      ),
                                                      const Gap(8),
                                                    ],
                                                  ),
                                                  ...(e.groupSets.elementAtOrNull(index)?.sets ?? [])
                                                      .map((e) => Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Gap(8),
                                                              Icon(
                                                                Icons.check,
                                                                // color: Theme.of(context).colorScheme.primary,
                                                                color: e.done ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                                                size: 12,
                                                              ),
                                                              const Gap(8),
                                                              Text(
                                                                e.meta.getFormatted(context),
                                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                                              ),
                                                            ],
                                                          ))
                                                      .toList(),
                                                ],
                                              ),
                                            )),
                                      ],
                                    );
                                  }).addBetween(const Gap(8)),
                                  const Gap(16),
                                ]),
                              ),
                            ),
                          ))
                    .toList()
                    .addBetween(const Gap(16)),
                const Gap(32),
              ],
            );
          },
        ),
      ),
    );
  }
}
