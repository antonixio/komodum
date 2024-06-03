import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/ui/widgets/c_empty_message/c_empty_message_widget.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/training_session_repository/training_session_repository.dart';
import '../../../data/repository/training_session_repository/training_session_resume_repository.dart';
import '../../../data/repository/training_template_repository/training_template_repository.dart';
import '../../../data/repository/training_template_repository/training_template_resume_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../../widgets/c_training_session_item/c_training_session_item_widget.dart';
import '../training_session/edit_training_session_screen.dart';

class _ListItemModel {
  final BehaviorSubject<bool> showHeader = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> deleted = BehaviorSubject.seeded(false);
  late final BehaviorSubject<TrainingSessionResumeModel> session;

  _ListItemModel({
    required bool showHeader,
    required bool deleted,
    required TrainingSessionResumeModel session,
  }) {
    this.showHeader.add(showHeader);
    this.deleted.add(deleted);
    this.session = BehaviorSubject.seeded(session);
  }
}

class TrainingSessionsScreen extends StatefulWidget {
  const TrainingSessionsScreen({super.key});

  @override
  State<TrainingSessionsScreen> createState() => _TrainingSessionsScreenState();
}

class _TrainingSessionsScreenState extends State<TrainingSessionsScreen> {
  final trainingSessionResumeRepository = GetIt.I.get<TrainingSessionResumeRepository>();
  static const _pageSize = 20;

  final PagingController<String, _ListItemModel> _pagingController = PagingController(firstPageKey: '');
  final List<_ListItemModel> items = [];
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      await Future.delayed(Durations.short2);
      final newItems = await trainingSessionResumeRepository.getSessions(lastOrder: pageKey, pageSize: 20);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        final addItems = getItems(newItems);
        items.addAll(addItems);
        _pagingController.appendLastPage(addItems);
      } else {
        final nextPageKey = pageKey + newItems.last.order;

        final addItems = getItems(newItems);
        items.addAll(addItems);
        _pagingController.appendPage(addItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  List<_ListItemModel> getItems(List<TrainingSessionResumeModel> sessions) {
    // final lastItem = items.firstWhereOrNull((element) => !element.deleted.value);
    return List.generate(sessions.length, (index) {
      bool showHeader = false;
      // if (index == 0) {
      //   showHeader = lastItem?.session.value.date.dateOnly() != sessions[index].date.dateOnly();
      // } else {
      //   showHeader = sessions[index - 1].date.dateOnly() != sessions[index].date.dateOnly();
      // }

      return _ListItemModel(showHeader: showHeader, deleted: false, session: sessions[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            IconButton(
              onPressed: () async {
                context.showMaterialModalBottomSheet(
                  (_) => ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_arrow, size: 12),
                        onTap: () {
                          context.pop();
                          final trainings = GetIt.I.get<TrainingTemplateResumeRepository>().data.value.where((element) => element.deletedAt == null);
                          context.showMaterialModalBottomSheet(
                            (_) => trainings.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: CEmptyMessageWidget(
                                      title: AppLocale.messageNothingHereYet.getTranslation(context),
                                      subtitle: AppLocale.messageCreateANewWorkout.getTranslation(context),
                                    ),
                                  )
                                : ListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(0),
                                    children: trainings
                                        .map(
                                          (e) => ListTile(
                                            visualDensity: VisualDensity.compact,
                                            title: Text(e.name),
                                            onTap: () async {
                                              context.pop();

                                              if (GetIt.I.get<TrainingSessionController>().hasOngoingSession) {
                                                if (!await CConfirmationDialogWidget.show(
                                                  context: context,
                                                  message: AppLocale.messageOngoingWorkoutSession.getTranslation(context),
                                                )) {
                                                  return;
                                                }
                                                GetIt.I.get<TrainingSessionController>().cancelOngoingTrainingSession();
                                              }
                                              try {
                                                context.loaderOverlay.show();
                                                final repository = GetIt.I.get<TrainingTemplateRepository>();

                                                final training = (await repository.getTrainings(id: e.id)).firstOrNull;
                                                context.loaderOverlay.hide();
                                                final session = training!.toSession();
                                                GetIt.I.get<TrainingSessionController>().updateOngoing(session);

                                                final saved = await context.push((context) => EditTrainingSessionScreen(trainingSession: session));
                                                if (saved == true) {
                                                  items.clear();
                                                  _pagingController.refresh();
                                                }
                                              } finally {
                                                if (context.loaderOverlay.visible) {
                                                  context.loaderOverlay.hide();
                                                }
                                              }
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ),
                          );
                        },
                        title: Text(AppLocale.labelStartFromWorkouts.getTranslation(context)),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_arrow, size: 12),
                        onTap: () async {
                          context.pop();

                          if (GetIt.I.get<TrainingSessionController>().hasOngoingSession) {
                            if (!await CConfirmationDialogWidget.show(
                              context: context,
                              message: AppLocale.messageOngoingWorkoutSession.getTranslation(context),
                            )) {
                              return;
                            }
                            GetIt.I.get<TrainingSessionController>().cancelOngoingTrainingSession();
                          }
                          final saved = await context.push(
                            (context) => EditTrainingSessionScreen(
                              trainingSession: TrainingSessionModel.dummy.copyWith(
                                id: null,
                                date: DateTime.now(),
                              ),
                            ),
                          );
                          if (saved == true) {
                            items.clear();
                            _pagingController.refresh();
                          }
                        },
                        title: Text(AppLocale.labelStartBlankSession.getTranslation(context)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: PagedListView<String, _ListItemModel>.separated(
          separatorBuilder: (_, __) => const Gap(8),
          padding: const EdgeInsets.all(16),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<_ListItemModel>(
            noItemsFoundIndicatorBuilder: (context) => CEmptyMessageWidget(
              title: AppLocale.messageNothingHereYet.getTranslation(context),
              subtitle: AppLocale.messageAddANewSessionToday.getTranslation(context),
            ),
            itemBuilder: (context, item, index) {
              return StreamBuilder(
                  stream: item.deleted,
                  initialData: item.deleted.value,
                  builder: (context, snapshot) {
                    final deleted = snapshot.data ?? false;
                    if (deleted) {
                      return const SizedBox.shrink();
                    }

                    return StreamBuilder(
                        stream: item.session,
                        initialData: item.session.value,
                        builder: (context, snapshotSession) {
                          final session = snapshotSession.data!;

                          return CTrainingSessionItemWidget(
                            trainingSessionResume: session,
                            onTap: () => edit(item),
                            onLongPress: () => showOptions(item),
                          );
                        });
                  });
            },
          ),
        ),
      ),
    );
  }

  Future<void> edit(_ListItemModel e) async {
    try {
      context.loaderOverlay.show();
      final repository = GetIt.I.get<TrainingSessionRepository>();

      final training = (await repository.getTrainings(id: e.session.value.id)).firstOrNull;
      context.loaderOverlay.hide();

      final saved = await context.push((context) => EditTrainingSessionScreen(trainingSession: training!, newSession: false));
      if (saved == true) {
        items.clear();
        _pagingController.refresh();
      }
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> showOptions(_ListItemModel e) async {
    context.showMaterialModalBottomSheet(
      (_) => ListView(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.edit, size: 12),
            onTap: () async {
              context.pop();

              edit(e);
            },
            title: Text(AppLocale.labelEdit.getTranslation(context)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.delete, size: 16),
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            title: Text(AppLocale.labelDelete.getTranslation(context)),
            onTap: () async {
              context.pop();
              bool confirm = await CConfirmationDialogWidget.show(
                context: context,
                message: AppLocale.labelConfirmGenericDeletion.getTranslation(context),
              );

              if (confirm) {
                await GetIt.I.get<TrainingSessionRepository>().delete(e.session.value.id);
                e.deleted.add(true);
              }
            },
          )
        ],
      ),
    );
  }
}
