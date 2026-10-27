import 'package:flutter/widgets.dart';

import 'models/course.dart';
import 'services/progress_store.dart';
import 'services/tts_service.dart';

/// Makes the course, progress store and TTS service available to every
/// screen without a state-management package.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.course,
    required this.progress,
    required this.tts,
    required super.child,
  });

  final Course course;
  final ProgressStore progress;
  final TtsService tts;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope old) =>
      course != old.course || progress != old.progress || tts != old.tts;
}
