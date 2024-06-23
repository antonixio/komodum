import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/util/helper/paywall_helper.dart';
import 'package:tiggym/src/util/services/purchase_service.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../controllers/training_session_controller.dart';
import '../../../data/repository/home_repository/home_repository.dart';
import '../../../util/helper/border_radius_max.dart';
import '../../widgets/c_drawer/c_drawer_widget.dart';
import '../../widgets/c_heatmap/c_heatmap.dart';
import '../../widgets/c_ongoing_training_session/c_ongoing_training_session_widget.dart';
import '../../widgets/c_shareable/c_shareable_widget.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      PaywallHelper.showPaywallOnInit(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          StreamBuilder(
              stream: PurchaseService.instance.isPremium,
              initialData: PurchaseService.instance.isPremium.value,
              builder: (context, snapshot) {
                if (snapshot.data ?? false) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusCircularMax(),
                    // color: Colors.blue,

                    gradient: const LinearGradient(
                      colors: [Color(0xffaaffa9), Color(0xff11ffbd)],
                      stops: [0, 1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        spreadRadius: -4,
                        blurRadius: 1,
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadiusCircularMax(),
                      // onTap: proceed,
                      onTap: () {
                        PaywallHelper.showPaywall(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocale.labelPro.getTranslation(context),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                // return ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     foregroundColor: Theme.of(context).colorScheme.onPrimary,
                //     backgroundColor: Theme.of(context).colorScheme.primary,
                //     visualDensity: VisualDensity.compact,
                //   ),
                //   onPressed: () async {
                //     PaywallHelper.showPaywall(context);
                //   },
                //   child: Text(AppLocale.labelPro.getTranslation(context)),
                // );
              }),
          const Gap(16)
        ],
      ),
      drawer: const CDrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        children: [
          const Gap(16),
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
                return Column(
                  children: [
                    CShareableWidget(
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
                              child: CHeatMap(
                                defaultColor: Theme.of(context).colorScheme.surfaceVariant,
                                startAt: DateTime.now().copyWith(year: DateTime.now().year - 2),
                                datasets: data.first.trainingSessions.map((key, value) => MapEntry(key, value.length)),
                                colorsets: {
                                  1: Theme.of(context).colorScheme.primary,
                                },
                              ),
                            ),
                            const Gap(12),
                          ],
                        ),
                      ),
                    ),
                    const Gap(48),
                    ...data.first.traininigSessionsTags.entries
                        .map<Widget>(
                          (item) => CShareableWidget(
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.label,
                                          size: 16,
                                          color: item.key.color,
                                        ),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            item.key.getName(context),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: CHeatMap(
                                      defaultColor: Theme.of(context).colorScheme.surfaceVariant,
                                      startAt: DateTime.now().copyWith(year: DateTime.now().year - 2),
                                      datasets: item.value.map((key, value) => MapEntry(key, value.length)),
                                      colorsets: {
                                        1: Theme.of(context).colorScheme.primary,
                                      },
                                    ),
                                  ),
                                  const Gap(12),
                                ],
                              ),
                            ),
                          ),
                        )
                        .addBetween(const Gap(16))
                  ],
                );
              }),
          const Gap(32),
        ],
      ),
    );
  }
}
