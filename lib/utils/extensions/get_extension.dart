import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

extension SafeUpdateGetxController on GetxController {
  /// Safely triggers GetX [update].
  /// If called while Flutter is mid-frame rendering ([SchedulerPhase.persistentCallbacks]),
  /// it schedules the update post-frame to prevent `performRebuild` / `markNeedsBuild` exceptions.
  void safeUpdate([List<Object>? ids, bool condition = true]) {
    if (!condition) return;
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(ids, condition);
      });
    } else {
      update(ids, condition);
    }
  }
}
