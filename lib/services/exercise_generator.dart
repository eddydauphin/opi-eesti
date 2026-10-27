import 'dart:math';

import '../models/course.dart';
import '../models/exercise.dart';
import 'text_utils.dart';

/// Builds a Duolingo-style exercise sequence from lesson content.
///
/// Content authors only write words and sentences; the generator turns them
/// into multiple-choice, word-bank, listening and matching exercises, with
/// distractors drawn from the rest of the course.
class ExerciseGenerator {
  ExerciseGenerator(this.course, {Random? random}) : _rng = random ?? Random();

  final Course course;
  final Random _rng;

  /// Exercises for one lesson, in a sensible teaching order: new words are
  /// introduced with easy picks first, then sentences, then recall.
  List<Exercise> forLesson(Lesson lesson, {bool includeListening = true}) {
    final unit = course.unitOfLesson(lesson.id);
    final poolWords = unit?.words ?? course.allWords;
    final out = <Exercise>[];

    // 1. Introduce each new word: Estonian -> English picks.
    for (final w in lesson.words) {
      out.add(_choice(w, poolWords, etToEn: true));
    }

    // 2. Match pairs once the words have been seen.
    if (lesson.words.length >= 3) {
      out.add(_matchPairs(lesson.words));
    }

    // 3. Sentences: build in Estonian, build in English, listen & type.
    final sentences = [...lesson.sentences]..shuffle(_rng);
    for (var i = 0; i < sentences.length; i++) {
      final s = sentences[i];
      final knownWords = _wordsIn(s, lesson, unit);
      switch (i % 3) {
        case 0:
          out.add(_buildSentence(s, knownWords, enToEt: true));
        case 1:
          out.add(_buildSentence(s, knownWords, enToEt: false));
        default:
          if (includeListening) {
            out.add(ListenTypeExercise(
              prompt: 'Type what you hear',
              wordKeys: knownWords,
              speakText: s.et,
              translation: s.en,
            ));
          } else {
            out.add(_buildSentence(s, knownWords, enToEt: true));
          }
      }
    }

    // 4. Recall: English -> Estonian picks for a few words.
    final recall = [...lesson.words]..shuffle(_rng);
    for (final w in recall.take(min(4, recall.length))) {
      out.add(_choice(w, poolWords, etToEn: false));
    }
    return out;
  }

  /// A review session for words that are due, mixing both directions and a
  /// matching exercise.
  List<Exercise> forReview(List<String> wordKeys, {int maxItems = 12}) {
    final words = <Word>[];
    for (final k in wordKeys) {
      final w = course.wordByEt(k);
      if (w != null) words.add(w);
      if (words.length >= maxItems) break;
    }
    if (words.isEmpty) return const [];

    final out = <Exercise>[];
    final pool = course.allWords;
    for (var i = 0; i < words.length; i++) {
      out.add(_choice(words[i], pool, etToEn: i.isEven));
    }
    if (words.length >= 3) {
      final shuffled = [...words]..shuffle(_rng);
      out.add(_matchPairs(shuffled.take(5).toList()));
    }
    // Add a sentence that uses one of the reviewed words, if any exists.
    for (final lesson in course.lessons) {
      for (final s in lesson.sentences) {
        final tokens = tokenize(s.et).map((t) => t.toLowerCase()).toSet();
        if (words.any((w) => tokens.contains(w.et.toLowerCase()))) {
          final known = _wordsIn(s, lesson, course.unitOfLesson(lesson.id));
          out.add(_buildSentence(s, known, enToEt: _rng.nextBool()));
          if (out.length >= maxItems + 3) return out..shuffle(_rng);
        }
      }
    }
    return out..shuffle(_rng);
  }

  ChoiceExercise _choice(Word word, List<Word> pool, {required bool etToEn}) {
    final others = pool.where((w) => w.et != word.et).toList()..shuffle(_rng);
    final distractors = <String>{};
    for (final o in others) {
      final text = etToEn ? o.en : o.et;
      if (text != (etToEn ? word.en : word.et)) distractors.add(text);
      if (distractors.length == 3) break;
    }
    // Small units: top up from the whole course.
    if (distractors.length < 3) {
      final all = course.allWords.where((w) => w.et != word.et).toList()..shuffle(_rng);
      for (final o in all) {
        distractors.add(etToEn ? o.en : o.et);
        if (distractors.length == 3) break;
      }
    }
    final options = [...distractors, etToEn ? word.en : word.et]..shuffle(_rng);
    final correct = options.indexOf(etToEn ? word.en : word.et);
    return ChoiceExercise(
      prompt: etToEn ? 'What does this mean?' : 'Which is the Estonian word?',
      wordKeys: [word.et],
      question: etToEn ? word.et : word.en,
      options: options,
      correctIndex: correct,
      speakText: etToEn ? word.et : null,
    );
  }

  MatchPairsExercise _matchPairs(List<Word> words) {
    final picked = [...words]..shuffle(_rng);
    final pairs = [for (final w in picked.take(5)) (w.et, w.en)];
    return MatchPairsExercise(
      prompt: 'Tap the matching pairs',
      wordKeys: [for (final p in pairs) p.$1],
      pairs: pairs,
    );
  }

  BuildSentenceExercise _buildSentence(Sentence s, List<String> wordKeys,
      {required bool enToEt}) {
    final answer = tokenize(enToEt ? s.et : s.en);
    final distractorPool = <String>{};
    final pool = [...course.allWords]..shuffle(_rng);
    final answerLower = answer.map((t) => t.toLowerCase()).toSet();
    for (final w in pool) {
      final text = enToEt ? w.et : w.en;
      // Only single words make good bank distractors.
      if (text.contains(' ') || text.contains('(')) continue;
      if (answerLower.contains(text.toLowerCase())) continue;
      distractorPool.add(text);
      if (distractorPool.length == 3) break;
    }
    final bank = [...answer, ...distractorPool]..shuffle(_rng);
    return BuildSentenceExercise(
      prompt: enToEt ? 'Translate into Estonian' : 'Translate into English',
      wordKeys: wordKeys,
      source: enToEt ? s.en : s.et,
      answerTokens: answer,
      bank: bank,
      acceptedAnswers: enToEt ? [s.et] : s.acceptedEn,
      speakText: enToEt ? null : s.et,
    );
  }

  /// Vocabulary keys from the lesson or unit that appear in a sentence.
  List<String> _wordsIn(Sentence s, Lesson lesson, Unit? unit) {
    final lower = ' ${normalizeAnswer(s.et)} ';
    final candidates = [...lesson.words, ...?unit?.words];
    final keys = <String>{};
    for (final w in candidates) {
      if (lower.contains(' ${normalizeAnswer(w.et)} ')) keys.add(w.et);
    }
    return keys.toList();
  }
}
