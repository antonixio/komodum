import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/model/connected_device_model.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_list/c_safe_view_list_widget.dart';
import 'package:tiggym_wear/src/util/extensions/build_context_extensions.dart';
import 'package:tiggym_wear/src/util/services/wear_connectivity_service.dart';

class FindDeviceScreen extends StatefulWidget {
  const FindDeviceScreen({super.key});

  @override
  State<FindDeviceScreen> createState() => _FindDeviceScreenState();
}

class _FindDeviceScreenState extends State<FindDeviceScreen> {
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        key: _refreshKey,
        future: WearConnectivityService.instance.getDevices(),
        builder: (context, snapshot) {
          final data = snapshot.data;

          if (data == null) {
            return CSafeViewContainerWidget(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocale.messageSearchingDevices.getTranslation(context)),
                    const Gap(16),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (data.isEmpty) {
            return CSafeViewContainerWidget(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocale.messageCouldntFindDevices.getTranslation(context)),
                    const Gap(8),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          _refreshKey = UniqueKey();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: CSafeViewListWidget(
              children: [
                ...data,
              ]
                  .map<Widget>(
                    (e) => FilledButton.icon(
                      onPressed: () {
                        WearConnectivityService.instance.saveConnectedDevice(ConnectedDeviceModel(deviceId: e.id, deviceName: e.name));
                        context.pushReplacementNamed('/home');
                      },
                      icon: const Icon(Icons.smartphone),
                      label: Text(e.name),
                    ),
                  )
                  .addBetween(const Gap(8))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
