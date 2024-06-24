import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/util/helper/paywall_helper.dart';
import 'package:tiggym/src/util/services/purchase_service.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/extensions/build_context_extensions.dart';

const activate = ["l-stats", "l-stats", "l-stats", "l-tags", "l-tags", "l-tags"];
final devActivated = BehaviorSubject.seeded(false);

class CDrawerWidget extends StatefulWidget {
  const CDrawerWidget({super.key});

  @override
  State<CDrawerWidget> createState() => _CDrawerWidgetState();
}

class _CDrawerWidgetState extends State<CDrawerWidget> {
  final actions = [];

  void updateActions(String action) {
    actions.add(action);
    if (actions.length > activate.length) {
      actions.removeRange(0, actions.length - activate.length - 1);
    }

    bool ok = true;
    for (var i = 0; i < activate.length; i++) {
      if (activate.elementAtOrNull(i) != actions.elementAtOrNull(i)) {
        ok = false;
        break;
      }
    }

    if (ok) {
      devActivated.add(ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(children: [
          // DrawerHeader(
          //   child: SizedBox(
          //     height: 80,
          //     width: 80,
          //     child: Center(
          //       child: GestureDetector(
          //           onTap: () {
          //             updateActions("img");
          //           },
          //           child: Image.asset('assets/icon/ic_front_crop.png')),
          //     ),
          //   ),
          // ),
          StreamBuilder(
              stream: PurchaseService.instance.isPremium,
              initialData: PurchaseService.instance.isPremium.value,
              builder: (context, snapshot) {
                if (snapshot.data ?? false) {
                  return DrawerHeader(
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Center(
                        child: GestureDetector(
                            onTap: () {
                              updateActions("img");
                            },
                            child: Image.asset('assets/icon/ic_front_crop.png')),
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    PaywallHelper.showPaywall(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffaaffa9), Color(0xff11ffbd)],
                        stops: [0, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocale.labelPro.getTranslation(context),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          AppLocale.labelBecomeASupporter.getTranslation(context),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.black,
                              ),
                        ),
                        const Gap(16),
                        ElevatedButton(
                          onPressed: () {
                            PaywallHelper.showPaywall(context);
                          },
                          style: ElevatedButton.styleFrom(
                              // backgroundColor: Colors.white,
                              // foregroundColor: Colors.black,
                              ),
                          child: Text(AppLocale.labelPro.getTranslation(context)),
                        )
                      ],
                    ),
                  ),
                );
              }),
          Expanded(
            child: ListView(
              children: [
                const Gap(16),
                ListTile(
                  onTap: () {
                    updateActions("stats");
                    if (!PurchaseService.instance.isPremium.value) {
                      PaywallHelper.showPaywall(context);
                      return;
                    }

                    context.pop();
                    Navigator.of(context).pushNamed('/stats');
                  },
                  onLongPress: () {
                    updateActions("l-stats");
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.diamond,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(8),
                        Text(AppLocale.labelStats.getTranslation(context)),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    updateActions("sessions");

                    context.pop();
                    Navigator.of(context).pushNamed('/sessions');
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(AppLocale.labelWorkoutSessions.getTranslation(context)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    updateActions("workouts");

                    context.pop();
                    Navigator.of(context).pushNamed('/workouts');
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(AppLocale.labelWorkouts.getTranslation(context)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    updateActions("exercises");

                    context.pop();
                    Navigator.of(context).pushNamed('/exercises');
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(AppLocale.labelExercises.getTranslation(context)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    updateActions("tags");

                    context.pop();
                    Navigator.of(context).pushNamed('/tags');
                  },
                  onLongPress: () {
                    updateActions("l-tags");
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(AppLocale.labelTags.getTranslation(context)),
                  ),
                ),

                ListTile(
                  onTap: () async {
                    updateActions("manage");
                    await launchUrl(Uri.parse("https://play.google.com/store/account/subscriptions"));
                  },
                  onLongPress: () {
                    updateActions("l-manage");
                  },
                  dense: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(AppLocale.labelManageSubscriptions.getTranslation(context)),
                  ),
                ),
                StreamBuilder(
                    stream: devActivated,
                    initialData: devActivated.value,
                    builder: (context, snapshot) {
                      if (!(snapshot.data ?? false)) {
                        return const SizedBox.shrink();
                      }
                      return ListTile(
                        onTap: () {
                          context.pop();
                          Navigator.of(context).pushNamed('/create_frequency');
                        },
                        dense: true,
                        title: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Create Frequency"),
                        ),
                      );
                    }),

                // const Gap(64),
                // StreamBuilder(
                //     stream: WearConnectivityService.instance.enabled,
                //     initialData: WearConnectivityService.instance.enabled.value,
                //     builder: (context, snapshot) {
                //       return SwitchListTile(
                //         onChanged: (v) => WearConnectivityService.instance.setEnabled(v),
                //         value: snapshot.data ?? false,
                //         dense: true,
                //         title: const Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 8.0),
                //           child: Text("Wear Sync"),
                //         ),
                //         subtitle: const Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 8.0),
                //           child: Text("Activate to use on your Wear OS Smartwatch"),
                //         ),
                //       );
                //     }),
                const Gap(32),
                // StreamBuilder(
                //     stream: PurchaseService.instance.isPremium,
                //     initialData: PurchaseService.instance.isPremium.value,
                //     builder: (context, snapshot) {
                //       if (!(snapshot.data ?? false)) {
                //         return Container(
                //           margin: const EdgeInsets.symmetric(horizontal: 16),
                //           clipBehavior: Clip.antiAlias,
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadiusCircularMax(),
                //             // color: Colors.blue,

                //             gradient: const LinearGradient(
                //               colors: [Color(0xffaaffa9), Color(0xff11ffbd)],
                //               stops: [0, 1],
                //               begin: Alignment.topLeft,
                //               end: Alignment.bottomRight,
                //             ),

                //             boxShadow: [
                //               BoxShadow(
                //                 color: Theme.of(context).colorScheme.primary,
                //                 spreadRadius: 1,
                //                 blurRadius: 5,
                //               ),
                //               BoxShadow(
                //                 color: Theme.of(context).colorScheme.primary,
                //                 spreadRadius: -4,
                //                 blurRadius: 1,
                //               )
                //             ],
                //           ),
                //           child: Material(
                //             color: Colors.transparent,
                //             child: InkWell(
                //               borderRadius: BorderRadiusCircularMax(),
                //               // onTap: proceed,
                //               onTap: () {
                //                 PaywallHelper.showPaywall(context);
                //               },
                //               child: Padding(
                //                 padding: const EdgeInsets.all(12.0),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Text(
                //                       AppLocale.labelPro.getTranslation(context),
                //                       textAlign: TextAlign.center,
                //                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //                             color: Colors.black,
                //                             fontWeight: FontWeight.w600,
                //                           ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         );
                //       }

                //       return const SizedBox.shrink();
                //     }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
