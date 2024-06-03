import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CShareScreenshotEditWidget extends StatefulWidget {
  final Uint8List image;
  const CShareScreenshotEditWidget({
    super.key,
    required this.image,
  });

  @override
  State<CShareScreenshotEditWidget> createState() => _CShareScreenshotEditWidgetState();
}

class _CShareScreenshotEditWidgetState extends State<CShareScreenshotEditWidget> {
  ScreenshotController screenshotController = ScreenshotController();

  List<LinearGradient> get gradients => [
        const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
        LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
          stops: const [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff00f5a0), Color(0xff00d9f5)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xffeb3349), Color(0xfff45c43)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff0052d4), Color(0xff4364f7), Color(0xff6fb1fc)],
          stops: [0, 0.5, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xffec008c), Color(0xfffc6767)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xffe52d27), Color(0xffb31217)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff02aab0), Color(0xff00cdac)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff16222a), Color(0xff3a6073)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xffffc500), Color(0xffc21500)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff00c6ff), Color(0xff0072ff)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xfff00000), Color(0xffdc281e)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff093028), Color(0xff237a57)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        const LinearGradient(
          colors: [Color(0xff003d4d), Color(0xff00c996)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      ];

  List<double> get ratios => [1, 16 / 9, 9 / 16];

  @override
  void initState() {
    super.initState();
  }

  late final selected = BehaviorSubject.seeded(gradients.skip(1).first);
  late final selectedRatio = BehaviorSubject.seeded(ratios.first);
  final capturing = BehaviorSubject.seeded(false);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        children: [
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ratios
                .map<Widget>(
                  (e) => StreamBuilder(
                      stream: selectedRatio,
                      initialData: selectedRatio.value,
                      builder: (context, snapshot) {
                        final data = snapshot.data!;
                        return Material(
                          borderRadius: BorderRadius.circular(100),
                          clipBehavior: Clip.antiAlias,
                          color: e == data ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              selectedRatio.add(e);
                            },
                            // isSelected: true,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Center(
                                  child: SizedBox(
                                    width: e > 1 ? 24 : 16,
                                    height: e < 1 ? 24 : 16,
                                    child: AspectRatio(
                                      aspectRatio: e,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 2,
                                            color: e == data ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        // color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                )
                .addBetween(const Gap(8))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: StreamBuilder(
                stream: selectedRatio,
                initialData: selectedRatio.value,
                builder: (context, snapshot) {
                  final selectedRatioData = snapshot.data;
                  return AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: StreamBuilder(
                          stream: selected,
                          initialData: selected.value,
                          builder: (context, snapshot) {
                            final data = snapshot.data!;
                            return Screenshot(
                              controller: screenshotController,
                              child: AspectRatio(
                                aspectRatio: selectedRatioData ?? 1,
                                child: LayoutBuilder(builder: (context, constraints) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: data,
                                      // color: Theme.of(context).colorScheme.primary,
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Center(
                                            child: AspectRatio(aspectRatio: selectedRatioData ?? 1, child: Image.memory(widget.image)),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: MediaQuery(
                                            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: min(18, max(constraints.maxHeight, constraints.maxWidth) * 0.5),
                                                  width: min(18, max(constraints.maxHeight, constraints.maxWidth) * 0.5),
                                                  child: Center(
                                                    child: Image.asset('assets/icon/icon-front.png'),
                                                  ),
                                                ),
                                                const Gap(4),
                                                Text(
                                                  "TigGym",
                                                  style: (Theme.of(context).textTheme.titleSmall ?? const TextStyle()).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: min(12, max(constraints.maxHeight, constraints.maxWidth) * 0.025),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                    ),
                  );
                }),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              const Gap(16),
              ...gradients
                  .map<Widget>(
                    (e) => StreamBuilder(
                        stream: selected,
                        initialData: selected.value,
                        builder: (context, snapshot) {
                          final data = snapshot.data!;
                          return AnimatedScale(
                            scale: data == e ? 0.8 : 1,
                            duration: Durations.short4,
                            child: GestureDetector(
                              onTap: () {
                                selected.add(e);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: e,
                                  border: Border.all(
                                    color: e.colors.first == Colors.transparent ? Colors.red : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    data == e ? 80 : 0,
                                  ),
                                ),
                                width: 30,
                                height: 30,
                                child: e.colors.first == Colors.transparent
                                    ? const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                  )
                  .toList()
                  .addBetween(const Gap(8)),
              const Gap(16),
            ]),
          ),
          const Gap(32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder(
                stream: capturing,
                initialData: capturing.value,
                builder: (context, snapshot) {
                  final data = snapshot.data ?? false;
                  return IconButton.filled(
                    onPressed: data ? null : share,
                    icon: data
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share),
                    // label: const Text("Share"),
                  );
                }),
          ),
          const Gap(16),
        ],
      ),
    );
  }

  Future<void> share() async {
    try {
      capturing.add(true);
      final dir = (await PathService.instance.getApplicationCacheDirectory2()).path;
      final image = await screenshotController.captureAndSave(
        dir,
        fileName: 'share.png',
        pixelRatio: 20,
      );
      if (image != null) {
        await Share.shareXFiles([XFile(image)]);
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      capturing.add(false);
    }
  }
}
