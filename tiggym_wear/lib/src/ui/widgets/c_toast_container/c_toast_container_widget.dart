import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_wear/src/ui/widgets/c_safe_view_container/c_safe_view_container_widget.dart';
import 'package:tiggym_wear/src/ui/widgets/c_toast_container/c_toast_controller.dart';

class CToastContainerWidget extends StatelessWidget {
  final Widget child;
  const CToastContainerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Positioned.fill(
          SizedBox(
            height: size.height,
            width: size.width,
            child: child,
          ),
          StreamBuilder(
              stream: GetIt.I.get<CToastController>().currentToast,
              initialData: null,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return Stack(
                  children: [
                    Container(
                      height: size.height,
                      width: size.width,
                      color: data != null ? Theme.of(context).colorScheme.onBackground.withOpacity(0.6) : null,
                    ),
                    AnimatedSlide(
                      offset: Offset(0, data == null ? -1 : 0),
                      duration: Durations.short4,
                      child: SizedBox(
                        height: size.height,
                        width: size.width,
                        child: CSafeViewContainerWidget(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: data,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
