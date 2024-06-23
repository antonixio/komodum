import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:tiggym/src/util/extensions/build_context_extensions.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../services/purchase_service.dart';

class PaywallHelper {
  static bool shown = false;
  static Future<void> showPaywallOnInit(BuildContext context) async {
    if (!shown && !PurchaseService.instance.isPremium.value) {
      showPaywall(context);
    }
  }

  static Future<void> showPaywall(BuildContext context) async {
    try {
      context.loaderOverlay.show();
      final offering = await PurchaseService.instance.getDefault();
      context.loaderOverlay.hide();

      context.showMaterialModalBottomSheet(
        (_) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Theme(
                    data: Theme.of(context),
                    child: PaywallView(
                      offering: offering,
                      onPurchaseStarted: (_) {},
                      onPurchaseCompleted: (info, _) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.messagePurchaseSucceeded.getTranslation(context))));
                      },
                      onPurchaseError: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.messagePurchaseError.getTranslation(context))));
                      },
                      onRestoreCompleted: (_) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.messageRestoreSucceeded.getTranslation(context))));
                      },
                      onRestoreError: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.messageRestoreSucceeded.getTranslation(context))));
                      },
                    ),
                  ),
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
      );
      // final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }
}
