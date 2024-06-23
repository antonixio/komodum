// import 'dart:async';
// import 'dart:ui';

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:gap/gap.dart';
// import 'package:pomodoro_app/src/data/enums/pomodoro_clock_view.dart';
// import 'package:pomodoro_app/src/util/extensions/iterable_extensions.dart';
// import '../../../../util/helper/border_radius_max.dart';
// import '../../../data/enums/pomodoro_session_type.dart';
// import '../../../services/purchase_service.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:rxdart/rxdart.dart';

// import '../../../data/constants/pomodoro_analytics.dart';
// import '../../../data/constants/pomodoro_colors.dart';
// import '../../../data/constants/pomodoro_purchase_constants.dart';
// import '../../../services/theme_service_v2.dart';
// import '../../../util/helper/border_radius_max.dart';
// import '../../../widgets/animated_entrance.dart';
// import '../../../widgets/card_container_widget.dart';
// import '../../../widgets/icon_widget.dart';
// import '../../../widgets/mockups/mockup_examples.dart';
// import '../../../widgets/mockups/smartphone_mockup_asset.dart';
// import '../../../widgets/snackbar/app_snack_bar.dart';
// import '../../../widgets/tappable_widget.dart';
// import '../../../widgets/text_widget/tags/scale_size_tag.dart';
// import '../../../widgets/text_widget/text_widget.dart';

// class GenericPaywall2 extends StatefulWidget {
//   final Offering offering;

//   late final String title;
//   late final String subtitle;

//   late final Package? weeklyPackage;
//   late final Package? monthlyPackage;
//   late final Package? lifetimePackage;
//   late final Package? annuallyPackage;

//   late final String weeklyLabel;
//   late final String monthlyLabel;
//   late final String annuallyLabel;
//   late final String lifetimeLabel;

//   late final String weeklyHighlight;
//   late final String monthlyHighlight;
//   late final String annuallyHighlight;
//   late final String lifetimeHighlight;

//   late final Package? selected;

//   late final bool showWeekly;
//   late final bool showMonthly;
//   late final bool showAnnually;
//   late final bool showLifetime;

//   late final BuildContext appContext;

//   GenericPaywall2({
//     super.key,
//     required this.offering,
//     required this.appContext,
//   }) {
//     title = offering.getMetadataString('title', "BE MORE PRODUCTIVE");
//     subtitle = offering.getMetadataString('subtitle', "Join premium today and supercharge your productivity");

//     weeklyLabel = offering.getMetadataString('weeklyLabel', '');
//     monthlyLabel = offering.getMetadataString('monthlyLabel', '');
//     annuallyLabel = offering.getMetadataString('annuallyLabel', '');
//     lifetimeLabel = offering.getMetadataString('lifetimeLabel', '');

//     weeklyHighlight = offering.getMetadataString('weeklyHighlight', '');
//     monthlyHighlight = offering.getMetadataString('monthlyHighlight', '');
//     annuallyHighlight = offering.getMetadataString('annuallyHighlight', '');
//     lifetimeHighlight = offering.getMetadataString('lifetimeHighlight', '');

//     showWeekly = offering.metadata['showWeekly'] == true;
//     showMonthly = offering.metadata['showMonthly'] == true;
//     showAnnually = offering.metadata['showAnnually'] == true;
//     showLifetime = offering.metadata['showLifetime'] == true;

//     weeklyPackage = offering.weekly;
//     monthlyPackage = offering.monthly;
//     lifetimePackage = offering.lifetime;
//     annuallyPackage = offering.annual;

//     selected = offering.getPackage(offering.getMetadataString('selected', '')) ??
//         packOrNull(weeklyPackage, showWeekly) ??
//         packOrNull(monthlyPackage, showMonthly) ??
//         packOrNull(annuallyPackage, showAnnually) ??
//         packOrNull(lifetimePackage, showLifetime);
//   }

//   Package? packOrNull(Package? package, bool show) => show ? package : null;

//   @override
//   State<GenericPaywall2> createState() => GenericPaywall2State();
// }

// class GenericPaywall2State extends State<GenericPaywall2> {
//   late final _selectedPackage = BehaviorSubject.seeded(widget.selected);
//   final _current = BehaviorSubject.seeded(0);

//   final kBenefitsWithIcons = [
//     BenefitModel(
//       icon: FontAwesomeIcons.bolt,
//       color: Colors.yellow.shade700,
//       benefit: "Supercharged Productivity",
//       description: 'Boost in productivity with pomodoro.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.solidEye,
//       color: Colors.purple,
//       benefit: "Better Focus",
//       description: 'Say good bye to distractions.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.image,
//       color: Colors.indigo,
//       benefit: "Add Background Image From Your Device",
//       description: 'Customize your background with any image in your device',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.palette,
//       color: Colors.lime,
//       benefit: "Use Different Layouts",
//       description: 'Use any of all the current and future available layouts',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.rectangleAd,
//       color: Colors.red,
//       benefit: "No More Ads",
//       description: 'Enjoy an ad-free Pomodoro experience that allows you to work and study without interruptions.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.chartPie,
//       color: Colors.green,
//       benefit: "Reports and Statistics",
//       description: 'Track your progress and performance with detailed reports and statistics.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.cloudArrowUp,
//       color: Colors.blue.shade600,
//       benefit: "Automatic Backup",
//       description: 'Setup backups to Google Drive',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.music,
//       color: Colors.pink,
//       benefit: "+80 Background Songs",
//       description: 'Customize your environment to boost your creativity and concentration.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.solidBell,
//       color: Colors.teal,
//       benefit: "+20 Alarm Sounds",
//       description: 'Wake up or transition between Pomodoro intervals with a variety of 20 alarm sounds.',
//     ),
//     BenefitModel(
//       icon: FontAwesomeIcons.solidHeart,
//       color: Colors.red,
//       secondaryColor: Colors.red,
//       benefit: "Support An Independent Dev",
//       description: "By choosing this Pomodoro app, you're not only investing in your productivity but also supporting an independent developer.",
//     ),
//   ];
  
//   @override
//   void initState() {
//     try {
//       // FirebaseAnalytics.instance.logEvent(name: '${kHasSeenPaywall}_${widget.offering.getMetadataString('id', '')}', parameters: {'paywall': 'generic', 'offer': widget.offering.identifier});
//     } finally {}
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final monthlyPack = widget.monthlyPackage;
//     final weeklyPack = widget.weeklyPackage;
//     final annuallyPack = widget.annuallyPackage;
//     final lifetimePack = widget.lifetimePackage;

//     return Scaffold(
//       body: Stack(
//         children: [
//           ListView(
//             children: [
//               Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: Opacity(
//                             opacity: 0.3,
//                             child: Image.asset(
//                               "assets/image/paywall_background.png",
//                               fit: BoxFit.cover,
//                               alignment: Alignment.center,
//                             ),
//                           ),
//                         ),
//                         const Gap(2),
//                       ],
//                     ),
//                   ),
//                   Positioned.fill(
//                     child: Container(
//                         decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                       colors: [
//                         Theme.of(context).colorScheme.background.withOpacity(0.0),
//                         Theme.of(context).colorScheme.background,
//                       ],
//                       stops: const [0.25, 0.9],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ))),
//                   ),
//                   // Column(
//                   //   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   //   children: [
//                   //     const Gap(8),
//                   //     Align(
//                   //       alignment: Alignment.topRight,
//                   //       child: Padding(
//                   //         padding: const EdgeInsets.all(8.0),
//                   //         child: TappableWidget(
//                   //           borderRadius: BorderRadiusCircularMax(),
//                   //           onTap: () {
//                   //             Navigator.of(context).maybePop();
//                   //           },
//                   //           child: Padding(
//                   //             padding: const EdgeInsets.all(8.0),
//                   //             child: SizedBox(
//                   //               height: 20,
//                   //               child: AspectRatio(
//                   //                 aspectRatio: 1,
//                   //                 child: IconWidget.sizedFa(FontAwesomeIcons.xmark, 20, color: Colors.white),
//                   //               ),
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     // const Gap(),
//                   //     AnimatedEntrance(
//                   //       delay: Duration.zero,
//                   //       child: Row(
//                   //         mainAxisAlignment: MainAxisAlignment.center,
//                   //         children: [
//                   //           ConstrainedBox(
//                   //             constraints: const BoxConstraints(maxWidth: 300),
//                   //             child: Text(
//                   //               widget.title,
//                   //               style: const TextStyle(
//                   //                 fontSize: 26,
//                   //                 fontWeight: FontWeight.bold,
//                   //                 letterSpacing: 1.3,
//                   //                 wordSpacing: 2.6,
//                   //                 color: Colors.white,
//                   //               ),
//                   //               textAlign: TextAlign.center,
//                   //             )
//                   //                 .animate(
//                   //                     onComplete: (c) => Future.delayed(const Duration(seconds: 2), () {
//                   //                           c.reset();
//                   //                           c.forward();
//                   //                         }))
//                   //                 .shake(duration: const Duration(seconds: 2), hz: 2),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //     // const Gap(16),
//                   //     // AnimatedEntrance(
//                   //     //   delay: Duration.zero,
//                   //     //   child: Container(
//                   //     //     constraints: const BoxConstraints(maxWidth: 300),
//                   //     //     margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                   //     //     child: Text(
//                   //     //       widget.subtitle,
//                   //     //       style: const TextStyle(
//                   //     //         fontSize: 14,
//                   //     //         letterSpacing: 1.3,
//                   //     //         wordSpacing: 2.6,
//                   //     //       ),
//                   //     //       textAlign: TextAlign.center,
//                   //     //     ),
//                   //     //   ),
//                   //     // ),
//                   //     const Gap(16),
//                   //     ...kBenefitsWithIcons
//                   //         .skip(2)
//                   //         .map((e) => Benefit3Widget(benefit: e.benefit, icon: IconWidget.sizedFa(e.icon, 14, color: e.secondaryColor ?? Colors.white), description: e.description))
//                   //         .toList()
//                   //         .asMap()
//                   //         .entries
//                   //         .map((e) => AnimatedEntrance(delay: Duration(milliseconds: 100 * e.key), child: e.value)),
//                   //     const Gap(16),
//                   //   ],
//                   // ),
                
//                 ],
//               ),
            
//               // Column(
//               //   children: [
//               //     const Gap(16),
//               //     if (weeklyPack != null && widget.showWeekly)
//               //       StreamBuilder(
//               //           stream: _selectedPackage,
//               //           initialData: _selectedPackage.value,
//               //           builder: (context, snapshot) {
//               //             return SubscriptionOption2(
//               //               onSelect: selectPackage,
//               //               appContext: widget.appContext,
//               //               package: weeklyPack,
//               //               title: "Weekly",
//               //               label: widget.weeklyLabel,
//               //               message: widget.weeklyHighlight,
//               //               selected: weeklyPack == snapshot.data,
//               //               price: getPriceFormatted(weeklyPack.storeProduct.priceString, weeklyPack.storeProduct.currencyCode, suffix: '/week'),
//               //             );
//               //           }),
//               //     if (monthlyPack != null && widget.showMonthly)
//               //       StreamBuilder(
//               //           stream: _selectedPackage,
//               //           initialData: _selectedPackage.value,
//               //           builder: (context, snapshot) {
//               //             return SubscriptionOption2(
//               //               onSelect: selectPackage,
//               //               appContext: widget.appContext,
//               //               package: monthlyPack,
//               //               title: "Monthly",
//               //               label: widget.monthlyLabel,
//               //               message: widget.monthlyHighlight,
//               //               selected: monthlyPack == snapshot.data,
//               //               price: getPriceFormatted(monthlyPack.storeProduct.priceString, monthlyPack.storeProduct.currencyCode, suffix: '/month'),
//               //             );
//               //           }),
//               //     if (annuallyPack != null && widget.showAnnually)
//               //       StreamBuilder(
//               //           stream: _selectedPackage,
//               //           initialData: _selectedPackage.value,
//               //           builder: (context, snapshot) {
//               //             return SubscriptionOption2(
//               //               onSelect: selectPackage,
//               //               appContext: widget.appContext,
//               //               package: annuallyPack,
//               //               title: "Annually",
//               //               label: widget.annuallyLabel,
//               //               message: widget.annuallyHighlight,
//               //               selected: annuallyPack == snapshot.data,
//               //               price: getPriceFormatted(annuallyPack.storeProduct.priceString, annuallyPack.storeProduct.currencyCode, suffix: '/year'),
//               //             );
//               //           }),
//               //     if ((annuallyPack != null && widget.showAnnually) || (weeklyPack != null && widget.showWeekly) || (monthlyPack != null && widget.showMonthly)) ...[
//               //       Padding(
//               //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               //         child: Text(
//               //           "Subscriptions auto-renew. You can cancel at anytime.",
//               //           textAlign: TextAlign.center,
//               //           style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
//               //         ),
//               //       ),
//               //       const Gap(4)
//               //     ],
//               //     if (lifetimePack != null && widget.showLifetime) ...[
//               //       const AnimatedEntrance(delay: Duration(milliseconds: 200), child: MyDivider()),
//               //       const Gap(8),
//               //       StreamBuilder(
//               //           stream: _selectedPackage,
//               //           initialData: _selectedPackage.value,
//               //           builder: (context, snapshot) {
//               //             return SubscriptionOption2(
//               //               onSelect: selectPackage,
//               //               appContext: widget.appContext,
//               //               package: lifetimePack,
//               //               title: "Lifetime",
//               //               label: widget.lifetimeLabel,
//               //               message: widget.lifetimeHighlight,
//               //               selected: lifetimePack == snapshot.data,
//               //               price: getPriceFormatted(lifetimePack.storeProduct.priceString, lifetimePack.storeProduct.currencyCode, suffix: " just once"),
//               //             );
//               //           }),
//               //     ],
//               //     const Gap(24),
//               //     AnimatedEntrance(
//               //       delay: Duration.zero,
//               //       child: CarouselSlider(
//               //         options: CarouselOptions(
//               //           autoPlay: true,
//               //           height: 240.0,
//               //           autoPlayAnimationDuration: const Duration(milliseconds: 1200),
//               //           viewportFraction: 1,
//               //           enlargeCenterPage: true,
//               //           enlargeStrategy: CenterPageEnlargeStrategy.height,
//               //           onPageChanged: (page, _) => _current.add(page),
//               //         ),
//               //         items: kBenefitsWithIcons
//               //             .map((e) => Center(
//               //                   child: Benefit2Widget(icon: IconWidget.sizedFa(e.icon, 20, color: e.color), benefit: e.benefit, description: e.description),
//               //                 ))
//               //             .toList(),
//               //       ),
//               //     ),
//               //     const Gap(16),
//               //     const Padding(
//               //       padding: EdgeInsets.all(16.0),
//               //       child: MockupExamples(),
//               //     ),
//               //     const Gap(200),
//               //   ],
//               // ),
            
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
                
//                 ClipRRect(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
//                     child: Container(
//                       color: Theme.of(context).colorScheme.background.withOpacity(0.8),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Gap(16),
//                           Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 16),
//                             clipBehavior: Clip.antiAlias,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadiusCircularMax(),
//                               // color: Colors.blue,

//                               gradient: const LinearGradient(
//                                 colors: [Color(0xffffd500), Color(0xfffbff00)],
//                                 stops: [0, 1],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),

//                               boxShadow: const [
//                                 BoxShadow(
//                                   color: Color(0xffffd500),
//                                   spreadRadius: 1,
//                                   blurRadius: 5,
//                                 ),
//                                 BoxShadow(
//                                   color: Color(0xffffd500),
//                                   spreadRadius: -4,
//                                   blurRadius: 1,
//                                 )
//                               ],
//                             ),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 borderRadius: BorderRadiusCircularMax(),
//                                 onTap: proceed,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         "Continue",
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Gap(8),
//                           Center(
//                             child: TextButton(
//                                 style: TextButton.styleFrom(visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
//                                 onPressed: restorePurchases,
//                                 child: Text(
//                                   "Restore Purchases",
//                                   style: Theme.of(context).textTheme.bodySmall,
//                                 )),
//                           ),
//                           const Gap(8),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> proceed() async {
//     final package = _selectedPackage.value;

//     if (package == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           AppSnackBar.normal(
//             context: context,
//             child: Text(
//               "Selected one of the available plans",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Theme.of(context).colorScheme.onBackground,
//               ),
//             ),
//             duration: const Duration(seconds: 3),
//             backgroundColor: Theme.of(context).canvasColor,
//           ),
//         );
//       }
//       return;
//     }

//     try {
//       FirebaseAnalytics.instance
//           .logEvent(name: '${kPomodoroAnalyticsTappedProceed}_${widget.offering.getMetadataString('id', '')}', parameters: {'paywall': 'generic', 'offer': widget.offering.identifier});
//       CustomerInfo customerInfo = await Purchases.purchasePackage(package);

//       if (customerInfo.entitlements.all[kPremiumEntitlement]?.isActive ?? false) {
//         FirebaseAnalytics.instance
//             .logEvent(name: '${kPomodoroAnalyticsPomodoroBecamePremium}_${widget.offering.getMetadataString('id', '')}', parameters: {'paywall': 'generic', 'offer': widget.offering.identifier});

//         if (mounted) {
//           Navigator.maybePop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             AppSnackBar.normal(
//               context: widget.appContext,
//               child: Text(
//                 "You're a premium user now 🎉",
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Theme.of(widget.appContext).colorScheme.onBackground,
//                 ),
//               ),
//               duration: const Duration(seconds: 3),
//               backgroundColor: Theme.of(widget.appContext).canvasColor,
//             ),
//           );
//         }
//         // Unlock that great "pro" content
//       }
//     } catch (_) {}
//   }

//   Future<void> restorePurchases() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       AppSnackBar.normal(
//         context: context,
//         child: Text(
//           "Trying to restore purchases",
//           style: TextStyle(
//             fontSize: 18,
//             color: Theme.of(context).colorScheme.onBackground,
//           ),
//         ),
//         duration: const Duration(seconds: 3),
//         backgroundColor: Theme.of(context).canvasColor,
//       ),
//     );
//     bool restored = await PurchaseService.instance.restorePurchases();
//     if (restored) {
//       FirebaseAnalytics.instance.logEvent(name: kPomodoroAnalyticsPomodoroRestorePremium);
//       if (mounted) {
//         Navigator.maybePop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           AppSnackBar.normal(
//             context: widget.appContext,
//             child: Text(
//               "Welcome back 🎉",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Theme.of(widget.appContext).colorScheme.onBackground,
//               ),
//             ),
//             duration: const Duration(seconds: 3),
//             backgroundColor: Theme.of(widget.appContext).canvasColor,
//           ),
//         );
//       }
//       // Unlock that great "pro" content
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           AppSnackBar.normal(
//             context: context,
//             child: Text(
//               "Couldn't find previous purchases",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Theme.of(context).colorScheme.onBackground,
//               ),
//             ),
//             duration: const Duration(seconds: 3),
//             backgroundColor: Theme.of(context).canvasColor,
//           ),
//         );
//       }
//     }
//   }

//   String getPriceFormatted(String price, String currencyCode, {String? suffix}) {
//     final suf = (suffix ?? '').isNotEmpty ? ScaleSizeTag().wrap('$suffix', 0.7) : '';
//     // final currentSymbol = kCurrency[currencyCode] ?? '';

//     return price + suf;
//   }

//   void selectPackage(Package package) {
//     _selectedPackage.add(package);
//   }
// }

// // class SubscriptionOption2 extends StatefulWidget {
// //   final String title;
// //   final String label;
// //   final Package package;
// //   final bool selected;
// //   final String price;
// //   final String? message;
// //   final BuildContext appContext;
// //   final Function(Package) onSelect;
// //   const SubscriptionOption2({
// //     super.key,
// //     required this.package,
// //     required this.title,
// //     required this.label,
// //     required this.price,
// //     required this.appContext,
// //     required this.onSelect,
// //     this.selected = false,
// //     this.message,
// //   });

// //   @override
// //   State<SubscriptionOption2> createState() => _SubscriptionOption2State();
// // }

// // class _SubscriptionOption2State extends State<SubscriptionOption2> {
// //   @override
// //   Widget build(BuildContext context) {
// //     final m = widget.message;
// //     return Container(
// //       margin: const EdgeInsets.only(
// //         left: 16.0,
// //         right: 16.0,
// //         bottom: 16.0,
// //       ),
// //       child: Stack(
// //         children: [
// //           CardContainerWidget(
// //             elevated: false,
// //             color: Theme.of(context).colorScheme.surface,
// //             border: Border.all(
// //               color: !widget.selected ? const Color(0xffffd500).withOpacity(0.1) : const Color(0xffffd500),
// //               width: 2,
// //             ),
// //             child: TappableWidget(
// //               onTap: () => widget.onSelect(widget.package),
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     // Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               TextWidget(
// //                                 text: widget.price.replaceAll('\n', 'replace'),
// //                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
// //                               ),
// //                               if (widget.label.isNotEmpty)
// //                                 Text(
// //                                   widget.label,
// //                                   style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 10),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                         const Gap(8.0),
// //                         Center(
// //                           child: AnimatedCrossFade(
// //                               firstChild: Container(
// //                                 decoration: BoxDecoration(borderRadius: BorderRadiusCircularMax(), color: const Color(0xffffd500)),
// //                                 width: 20,
// //                                 height: 20,
// //                                 child: Center(
// //                                   child: IconWidget.sizedFa(FontAwesomeIcons.check, 16, color: Colors.black),
// //                                 ),
// //                               ),
// //                               secondChild: Container(
// //                                 decoration: BoxDecoration(
// //                                   borderRadius: BorderRadiusCircularMax(),
// //                                   border: Border.all(
// //                                     color: const Color(0xffffd500).withOpacity(0.1),
// //                                     width: 2,
// //                                   ),
// //                                 ),
// //                                 width: 20,
// //                                 height: 20,
// //                               ),
// //                               crossFadeState: widget.selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
// //                               duration: const Duration(milliseconds: 200)),
// //                         ),
// //                         // IconWidget.sizedFa(FontAwesomeIcons.chevronRight, 12)
// //                       ],
// //                     ),
// //                     if (m != null && m.isNotEmpty) const Gap(16)
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           if (m != null && m.isNotEmpty)
// //             Positioned(
// //               bottom: 2,
// //               left: 16,
// //               right: 16,
// //               child: Transform.scale(
// //                 scale: 1.1,
// //                 child: Container(
// //                   decoration: const BoxDecoration(
// //                     color: Color(0xffffd500),
// //                     borderRadius: BorderRadius.only(
// //                       bottomLeft: Radius.circular(10),
// //                       bottomRight: Radius.circular(10),
// //                     ),
// //                   ),
// //                   margin: const EdgeInsets.only(top: 4.0),
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 16.0,
// //                       vertical: 2.0,
// //                     ),
// //                     child: Text(
// //                       m,
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Theme.of(context).colorScheme.onPrimary,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             )
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class BenefitWidget extends StatelessWidget {
// //   final String benefit;
// //   final Widget? icon;
// //   const BenefitWidget({
// //     super.key,
// //     required this.benefit,
// //     this.icon,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(
// //         right: 16.0,
// //         left: 48.0,
// //         bottom: 12.0,
// //       ),
// //       child: Row(
// //         children: [
// //           icon ??
// //               CardContainerWidget(
// //                 elevated: false,
// //                 color: AppColors.primary,
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(4.0),
// //                   child: IconWidget.sizedFa(
// //                     FontAwesomeIcons.crown,
// //                     14,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //           const Gap(16.0),
// //           Expanded(
// //               child: Text(
// //             benefit,
// //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class Benefit3Widget extends StatelessWidget {
// //   final String benefit;
// //   final String description;
// //   final Widget icon;
// //   const Benefit3Widget({
// //     super.key,
// //     required this.benefit,
// //     required this.icon,
// //     required this.description,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(
// //         right: 16.0,
// //         left: 48.0,
// //       ),
// //       child: Row(
// //         children: [
// //           CardContainerWidget(
// //             elevated: false,
// //             color: Colors.transparent,
// //             child: SizedBox(
// //               width: 18,
// //               height: 18,
// //               child: Center(
// //                 child: icon,
// //               ),
// //             ),
// //           ),
// //           const Gap(16.0),
// //           Expanded(
// //               child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Text(
// //                 benefit,
// //                 style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 10),
// //               ),
// //             ],
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class Benefit2Widget extends StatelessWidget {
// //   final String benefit;
// //   final String description;
// //   final Widget icon;
// //   const Benefit2Widget({
// //     super.key,
// //     required this.benefit,
// //     required this.icon,
// //     required this.description,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: Card(
// //             clipBehavior: Clip.antiAlias,
// //             color: Theme.of(context).colorScheme.surface,
// //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CardContainerWidget(
// //                     elevated: false,
// //                     color: Colors.white,
// //                     child: SizedBox(
// //                       width: 32,
// //                       height: 32,
// //                       child: Center(
// //                         child: icon,
// //                       ),
// //                     ),
// //                   ),
// //                   const Gap(8.0),
// //                   Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     crossAxisAlignment: CrossAxisAlignment.center,
// //                     children: [
// //                       Text(
// //                         benefit,
// //                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const Gap(4),
// //                       Text(
// //                         description,
// //                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8)),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class MyDivider extends StatelessWidget {
// //   const MyDivider({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Opacity(
// //       opacity: 0.4,
// //       child: Row(
// //         children: [
// //           const Gap(64),
// //           Expanded(
// //             child: Container(
// //               height: 0,
// //               decoration: const BoxDecoration(
// //                   border: Border(
// //                 bottom: BorderSide(
// //                   style: BorderStyle.solid,
// //                   width: 2,
// //                   color: Color(0xffffd500),
// //                 ),
// //               )),
// //             ),
// //           ),
// //           const Gap(16),
// //           const Icon(Icons.spa, color: Color(0xffffd500), size: 24),
// //           const Gap(16),
// //           Expanded(
// //             child: Container(
// //               height: 0,
// //               decoration: const BoxDecoration(
// //                   border: Border(
// //                 bottom: BorderSide(
// //                   width: 2,
// //                   color: Color(0xffffd500),
// //                 ),
// //               )),
// //             ),
// //           ),
// //           const Gap(64),
// //         ],
// //       ),
// //     );
// //   }
// // }
