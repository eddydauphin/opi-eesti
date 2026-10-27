import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress.dart';

/// Owns the learner's [Progress], persists it on the device and notifies the
/// UI when it changes.
class ProgressStore extends ChangeNotifier {
  ProgressStore({Progress? initial, this.clock = DateTime.now})
      : progress = initial ?? Progress();

  static const _prefsKey = 'progress_v1';

  Progress progress;
  final DateTime Function() clock;

  static Future<ProgressStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    Progress? initial;
    if (raw != null) {
      try {
        initial = Progress.decode(raw);
      } catch (_) {
        initial = null; // Corrupt data: start fresh rather than crash.
      }
    }
    return ProgressStore(initial: initial);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, progress.encode());
  }

  int get xp => progress.xp;
  int get streak => progress.streakAt(clock());
  bool isLessonDone(String id) => progress.isLessonDone(id);
  List<String> get dueWords => progress.dueWords(clock());

  /// Called when a lesson or review session finishes.
  Future<void> completeSession({
    String? lessonId,
    required int xpEarned,
    required Map<String, bool> wordResults,
  }) async {
    final now = clock();
    if (lessonId != null) progress.completedLessons.add(lessonId);
    progress.xp += xpEarned;
    progress.markActive(now);
    for (final e in wordResults.entries) {
      progress.recordAnswer(e.key, correct: e.value, now: now);
    }
    notifyListeners();
    await _save();
  }

  Future<void> reset() async {
    progress = Progress();
    notifyListeners();
    await _save();
  }
}
