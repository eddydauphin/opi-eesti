import '../models/exercise.dart';
import 'text_utils.dart';

/// Drives one lesson or review session: serves exercises in order, puts
/// mistakes back at the end of the queue until they are answered correctly
/// (as Duolingo does), and keeps score.
class LessonSession {
  LessonSession(List<Exercise> exercises, {this.lessonId})
      : _queue = List.of(exercises),
        totalExercises = exercises.length;

  final String? lessonId;
  final List<Exercise> _queue;
  final int totalExercises;

  int _completed = 0;
  int mistakes = 0;

  /// First-attempt result per vocabulary key; feeds spaced repetition.
  final Map<String, bool> wordResults = {};

  bool get isFinished => _queue.isEmpty;
  Exercise? get current => _queue.isEmpty ? null : _queue.first;

  /// 0..1 progress for the progress bar. Re-queued mistakes do not move it
  /// backwards; they just delay the end.
  double get progress => totalExercises == 0 ? 1 : _completed / totalExercises;

  int get xpEarned {
    if (totalExercises == 0) return 0;
    final base = lessonId != null ? 10 : 5;
    final bonus = mistakes == 0 ? 5 : 0;
    return base + bonus;
  }

  /// Share of exercises solved on the first try.
  double get accuracy => totalExercises == 0
      ? 1
      : ((totalExercises - mistakes).clamp(0, totalExercises)) / totalExercises;

  /// Records the outcome of the current exercise and advances the queue.
  void submit({required bool correct}) {
    final ex = _queue.removeAt(0);
    for (final k in ex.wordKeys) {
      wordResults.putIfAbsent(k, () => correct);
      if (!correct) wordResults[k] = false;
    }
    if (correct) {
      _completed += 1;
    } else {
      mistakes += 1;
      _queue.add(ex);
    }
  }

  /// Removes a matching exercise that was just re-queued after mistakes:
  /// matching corrects itself on screen, so repeating it teaches nothing.
  void skipMatchRepeat() {
    if (_queue.isNotEmpty && _queue.last is MatchPairsExercise) {
      _queue.removeLast();
      _completed += 1;
    }
  }

  /// Drops every remaining listening exercise, for when the learner cannot
  /// listen right now (no voice installed, or a quiet cabin).
  void skipListening() {
    final before = _queue.length;
    _queue.removeWhere((e) => e is ListenTypeExercise);
    _completed += before - _queue.length;
  }

  static bool checkChoice(ChoiceExercise ex, int? selected) =>
      selected != null && selected == ex.correctIndex;

  static bool checkBuild(BuildSentenceExercise ex, List<String> tokens) =>
      answersMatch(tokens.join(' '), ex.acceptedAnswers);

  static bool checkTyped(ListenTypeExercise ex, String typed) =>
      answersMatch(typed, [ex.speakText]);
}
