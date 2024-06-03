import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/home_repository/home_repository.dart';
import '../../widgets/c_drawer/c_drawer_widget.dart';
import '../../widgets/c_ongoing_training_session/c_ongoing_training_session_widget.dart';
import '../../widgets/c_sharable/c_sharable_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeRepository = GetIt.I.get<HomeRepository>();
  final selectedTrainings = BehaviorSubject.seeded(<TrainingTemplateResumeModel>[]);
  final trainingSessionController = GetIt.I.get<TrainingSessionController>();

  final dates = BehaviorSubject.seeded(<DateTime, int>{});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      drawer: const CDrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        children: [
          StreamBuilder(
              stream: trainingSessionController.ongoingSession,
              initialData: trainingSessionController.ongoingSession.value,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      COngoingTrainingSessionWidget(trainingSession: data),
                      const Gap(16),
                    ],
                  );
                }

                return const SizedBox.shrink();
              }),
          StreamBuilder(
              stream: homeRepository.data,
              initialData: homeRepository.data.value,
              builder: (context, snapshot) {
                final data = snapshot.data!;
                return CSharableWidget(
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppLocale.labelHomeFrequency.getTranslation(context),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: HeatMap(
                            defaultColor: Theme.of(context).colorScheme.surfaceVariant,
                            colorMode: ColorMode.color,
                            fontSize: 0,
                            startDate: DateTime.now().copyWith(day: 1, month: 1, year: DateTime.now().year - 5),
                            size: 10,
                            borderRadius: 2,
                            margin: const EdgeInsets.all(1.2),
                            scrollable: true,
                            datasets: data.first.trainingSessions.map((key, value) => MapEntry(key, value.length)),
                            showColorTip: false,
                            showText: false,
                            // onClick: (_) => onTap(),
                            colorsets: {
                              1: Theme.of(context).colorScheme.primary,
                            },
                          ),
                        ),
                        const Gap(12),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
