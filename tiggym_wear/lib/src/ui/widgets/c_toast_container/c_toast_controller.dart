import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CToastController {
  final _currentToast = BehaviorSubject<Widget?>.seeded(null);
  ValueStream<Widget?> get currentToast => _currentToast;
  final List<(Widget, Duration)> toasts = [];

  void addWidget({
    required Widget child,
    Duration? duration,
  }) {
    toasts.add((child, duration ?? const Duration(seconds: 2)));
    if (toasts.length == 1) {
      showToast();
    }
  }

  void addText({
    required String text,
    Duration? duration,
  }) {
    addWidget(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.8),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        duration: duration);
  }

  void showToast() async {
    final nextToast = toasts.firstOrNull;
    if (nextToast != null) {
      _currentToast.add(nextToast.$1);
      await Future.delayed(nextToast.$2);
      toasts.remove(nextToast);
      _currentToast.add(null);
      await Future.delayed(Durations.extralong4);
      showToast();
    }
  }
}
