import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/data/constants/purchases_constants.dart';

import '../../data/models/store_config.dart';

class PurchaseService {
  final _isPremium = BehaviorSubject.seeded(false);
  ValueStream<bool> get isPremium => _isPremium;

  final _initialized = BehaviorSubject.seeded(false);
  ValueStream<bool> get initialized => _initialized;

  PurchaseService._privateConstructor();

  static final PurchaseService instance = PurchaseService._privateConstructor();

  Future<void> initialize() async {
    StoreConfig(
      store: Store.playStore,
      apiKey: PurchasesConstants.kGoogleApiKey,
    );
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = PurchasesConfiguration(StoreConfig.instance.apiKey);

    await Purchases.configure(configuration);
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    _isPremium.add(isPremiumEnabled(customerInfo));
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _isPremium.add(isPremiumEnabled(customerInfo));
    });
    _initialized.add(true);
    // await Purchases.enableAdServicesAttributionTokenCollection();
  }

  Future<Offering?> getDefault() async {
    Offerings offerings = await Purchases.getOfferings();
    // final defaultOfferingId =
    //     FirebaseRemoteConfig.instance.getString("default_offering_id");

    return
        // offerings.getOffering(defaultOfferingId) ??
        // offerings.getOffering('generic_v2') ??
        offerings.current;
  }

  // Future<Offering?> getOffering({String id = ''}) async {
  //   Offerings offerings = await Purchases.getOfferings();
  //   final defaultOfferingId =
  //       FirebaseRemoteConfig.instance.getString("default_offering_id");
  //   return offerings.getOffering(id) ??
  //       offerings.getOffering(defaultOfferingId) ??
  //       offerings.current;
  // }

  Future<Offering?> getOfferingById({String id = ''}) async {
    Offerings offerings = await Purchases.getOfferings();
    return offerings.getOffering(id);
  }

  Future<bool> restorePurchases() async {
    CustomerInfo customerInfo = await Purchases.restorePurchases();
    _isPremium.add(isPremiumEnabled(customerInfo));
    return isPremiumEnabled(customerInfo);
  }

  Future<bool> purchasePackage(Package package) async {
    CustomerInfo customerInfo = await Purchases.purchasePackage(package);
    _isPremium.add(isPremiumEnabled(customerInfo));
    return isPremiumEnabled(customerInfo);
  }

  bool isPremiumEnabled(CustomerInfo customerInfo) => (customerInfo.entitlements.all[PurchasesConstants.kPremiumEntitlement]?.isActive ?? false);

  void validate(CustomerInfo customerInfo) => _isPremium.add(isPremiumEnabled(customerInfo));
  // bool isPremiumEnabled(CustomerInfo customerInfo) => true;
}
