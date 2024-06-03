import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CConfirmationDialogWidget extends StatelessWidget {
  final String message;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final bool showConfirmButton;
  const CConfirmationDialogWidget({
    super.key,
    required this.message,
    this.confirmButtonText,
    this.cancelButtonText,
    this.showConfirmButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(
        Icons.warning,
        color: Theme.of(context).colorScheme.error,
        size: 36,
      ),
      // insetPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      content: Text(message),
      actions: [
        if (showConfirmButton)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              Navigator.of(context).maybePop(true);
            },
            child: Text(confirmButtonText ?? AppLocale.labelConfirm.getTranslation(context)),
          ),
        TextButton(
          style: TextButton.styleFrom(
            // backgroundColor: Theme.of(context).colorScheme.primary,
            // foregroundColor: Theme.of(context).colorScheme.onPrimary,
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () {
            Navigator.of(context).maybePop(false);
          },
          child: Text(showConfirmButton ? (cancelButtonText ?? AppLocale.labelCancel.getTranslation(context)) : confirmButtonText ?? AppLocale.labelConfirm.getTranslation(context)),
        ),
      ],
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String message,
    String? confirmButtonText,
    String? cancelButtonText,
  }) async {
    final result = await showDialog(
      context: context,
      builder: (_) => CConfirmationDialogWidget(
        cancelButtonText: cancelButtonText,
        confirmButtonText: confirmButtonText,
        message: message,
      ),
    );
    return result == true;
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String message,
    String? confirmButtonText,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => CConfirmationDialogWidget(
        cancelButtonText: confirmButtonText,
        showConfirmButton: false,
        message: message,
      ),
    );
  }
}
