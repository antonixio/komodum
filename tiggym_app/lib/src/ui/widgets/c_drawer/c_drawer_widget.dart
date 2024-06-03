import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym/src/util/services/wear_connectivity_service.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../util/extensions/build_context_extensions.dart';

class CDrawerWidget extends StatelessWidget {
  const CDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        Expanded(
          child: ListView(
            children: [
              const Gap(64),
              ListTile(
                onTap: () {
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
                  context.pop();
                  Navigator.of(context).pushNamed('/tags');
                },
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(AppLocale.labelTags.getTranslation(context)),
                ),
              ),
              const Gap(64),
              StreamBuilder(
                  stream: WearConnectivityService.instance.enabled,
                  initialData: WearConnectivityService.instance.enabled.value,
                  builder: (context, snapshot) {
                    return SwitchListTile(
                      onChanged: (v) => WearConnectivityService.instance.setEnabled(v),
                      value: snapshot.data ?? false,
                      dense: true,
                      title: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Wear Sync"),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Activate to use on your Wear OS Smartwatch"),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ]),
    );
  }
}
