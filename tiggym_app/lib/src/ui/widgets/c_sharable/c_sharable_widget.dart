import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../../../util/extensions/build_context_extensions.dart';
import '../c_share_screenshot_edit/c_share_screenshot_edit_widget.dart';

class CSharableWidget extends StatefulWidget {
  final Widget child;
  final double top;
  final double right;
  const CSharableWidget({
    super.key,
    required this.child,
    this.top = 0,
    this.right = 0,
  });

  @override
  State<CSharableWidget> createState() => _CSharableWidgetState();
}

class _CSharableWidgetState extends State<CSharableWidget> {
  bool capturing = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Screenshot(controller: screenshotController, child: widget.child),
        Positioned(
          top: widget.top,
          right: widget.right,
          child: IconButton(
            onPressed: !capturing ? capture : null,
            iconSize: 16,
            icon: capturing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
          ),
        )
      ],
    );
  }

  Future<void> capture() async {
    try {
      setState(() => capturing = true);
      final image = await screenshotController.capture(pixelRatio: 20);
      if (image != null) {
        context.showMaterialModalBottomSheet((context) => CShareScreenshotEditWidget(image: image));
      }
    } finally {
      setState(() => capturing = false);
    }
  }
}
