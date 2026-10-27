/// The exercise types a lesson can contain. They mirror the classic
/// Duolingo formats: pick the right translation, build a sentence from a
/// word bank, type what you hear, and match pairs.
enum ExerciseKind { choice, buildSentence, listenType, matchPairs }

sealed class Exercise {
  Exercise({required this.prompt, required this.wordKeys});

  /// Text shown at the top of the exercise.
  final String prompt;

  /// Estonian vocabulary keys this exercise practises, for spaced repetition.
  final List<String> wordKeys;

  ExerciseKind get kind;
}

/// Pick the correct translation out of several options.
class ChoiceExercise extends Exercise {
  ChoiceExercise({
    required super.prompt,
    required super.wordKeys,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.speakText,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  /// Estonian text to read aloud when the exercise opens, if any.
  final String? speakText;

  @override
  ExerciseKind get kind => ExerciseKind.choice;
}

/// Translate a sentence by tapping words from a word bank in the right order.
class BuildSentenceExercise extends Exercise {
  BuildSentenceExercise({
    required super.prompt,
    required super.wordKeys,
    required this.source,
    required this.answerTokens,
    required this.bank,
    required this.acceptedAnswers,
    required this.speakText,
  });

  final String source;
  final List<String> answerTokens;

  /// Shuffled tokens, answer tokens plus distractors.
  final List<String> bank;
  final List<String> acceptedAnswers;
  final String? speakText;

  @override
  ExerciseKind get kind => ExerciseKind.buildSentence;
}

/// Listen to Estonian audio and type what was said.
class ListenTypeExercise extends Exercise {
  ListenTypeExercise({
    required super.prompt,
    required super.wordKeys,
    required this.speakText,
    required this.translation,
  });

  final String speakText;
  final String translation;

  @override
  ExerciseKind get kind => ExerciseKind.listenType;
}

/// Match Estonian words with their English meaning.
class MatchPairsExercise extends Exercise {
  MatchPairsExercise({
    required super.prompt,
    required super.wordKeys,
    required this.pairs,
  });

  /// Each entry is (Estonian, English).
  final List<(String, String)> pairs;

  @override
  ExerciseKind get kind => ExerciseKind.matchPairs;
}
