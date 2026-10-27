import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:opi_eesti/models/course.dart';
import 'package:opi_eesti/models/exercise.dart';
import 'package:opi_eesti/models/progress.dart';
import 'package:opi_eesti/services/exercise_generator.dart';
import 'package:opi_eesti/services/lesson_session.dart';
import 'package:opi_eesti/services/text_utils.dart';

void main() {
  late Course course;

  setUpAll(() {
    final raw = File('assets/course/course.json').readAsStringSync();
    course = Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  group('answer normalisation', () {
    test('ignores case, punctuation and spacing but keeps diacritics', () {
      expect(answersMatch('tere,  Kuidas läheb', ['Tere, kuidas läheb?']), isTrue);
      expect(answersMatch('tere kuidas laheb', ['Tere, kuidas läheb?']), isFalse);
      expect(answersMatch("I don't understand", ['I do not understand', "I don't understand"]), isTrue);
    });

    test('tokenize drops punctuation', () {
      expect(tokenize('Tere, kuidas läheb?'), ['Tere', 'kuidas', 'läheb']);
    });
  });

  group('exercise generator', () {
    test('builds a full lesson with every exercise type', () {
      final gen = ExerciseGenerator(course, random: Random(1));
      final ex = gen.forLesson(course.lessons.first);
      expect(ex.whereType<ChoiceExercise>(), isNotEmpty);
      expect(ex.whereType<BuildSentenceExercise>(), isNotEmpty);
      expect(ex.whereType<ListenTypeExercise>(), isNotEmpty);
      expect(ex.whereType<MatchPairsExercise>(), isNotEmpty);
    });

    test('choice exercises have four distinct options including the answer', () {
      final gen = ExerciseGenerator(course, random: Random(2));
      for (final lesson in course.lessons) {
        for (final ex in gen.forLesson(lesson).whereType<ChoiceExercise>()) {
          expect(ex.options.length, 4);
          expect(ex.options.toSet().length, 4);
          expect(ex.correctIndex, inInclusiveRange(0, 3));
        }
      }
    });

    test('word bank contains the whole answer plus distractors', () {
      final gen = ExerciseGenerator(course, random: Random(3));
      for (final lesson in course.lessons) {
        for (final ex in gen.forLesson(lesson).whereType<BuildSentenceExercise>()) {
          expect(ex.bank.length, greaterThan(ex.answerTokens.length));
          for (final t in ex.answerTokens) {
            expect(ex.bank, contains(t));
          }
          expect(LessonSession.checkBuild(ex, ex.answerTokens), isTrue);
        }
      }
    });

    test('listening can be left out', () {
      final gen = ExerciseGenerator(course, random: Random(4));
      final ex = gen.forLesson(course.lessons.first, includeListening: false);
      expect(ex.whereType<ListenTypeExercise>(), isEmpty);
    });

    test('review session uses the requested words', () {
      final gen = ExerciseGenerator(course, random: Random(5));
      final ex = gen.forReview(['tere', 'aitäh', 'jah']);
      expect(ex, isNotEmpty);
      final keys = ex.expand((e) => e.wordKeys).toSet();
      expect(keys, containsAll(['tere', 'aitäh', 'jah']));
    });

    test('generates valid exercises in French and Spanish too', () {
      for (final lang in ['fr', 'es']) {
        final gen = ExerciseGenerator(course, lang: lang, random: Random(7));
        for (final lesson in course.lessons) {
          final exercises = gen.forLesson(lesson);
          for (final ex in exercises) {
            switch (ex) {
              case ChoiceExercise():
                expect(ex.options.toSet().length, 4, reason: '$lang ${lesson.id} ${ex.question}');
              case BuildSentenceExercise():
                expect(LessonSession.checkBuild(ex, ex.answerTokens), isTrue,
                    reason: '$lang ${lesson.id} ${ex.source}');
              case ListenTypeExercise():
                expect(ex.translation, isNotEmpty);
              case MatchPairsExercise():
                expect(ex.pairs.map((p) => p.$2).toSet().length, ex.pairs.length);
            }
          }
        }
      }
      final fr = ExerciseGenerator(course, lang: 'fr', random: Random(8))
          .forLesson(course.lessons.first)
          .whereType<ChoiceExercise>()
          .first;
      expect(fr.prompt, 'Que veut dire ce mot ?');
    });
  });

  group('lesson session', () {
    test('French answers are checked against French alternatives', () {
      final s = course.lessons.first.sentences
          .firstWhere((s) => s.et == 'Tere, kuidas läheb?');
      expect(answersMatch('salut ça va', s.accepted('fr')), isTrue);
      expect(answersMatch('hola que tal', s.accepted('es')), isFalse);
      expect(answersMatch('Hola, ¿qué tal?', s.accepted('es')), isTrue);
    });

    test('wrong answers are repeated until correct', () {
      final gen = ExerciseGenerator(course, random: Random(6));
      final session = LessonSession(gen.forLesson(course.lessons.first), lessonId: 'u1l1');
      final first = session.current!;
      session.submit(correct: false);
      expect(session.mistakes, 1);
      expect(session.progress, 0);
      var steps = 0;
      while (!session.isFinished) {
        session.submit(correct: true);
        steps++;
      }
      expect(steps, session.totalExercises);
      expect(session.wordResults[first.wordKeys.first], isFalse);
      expect(session.xpEarned, 10);
    });

    test('perfect lesson earns the bonus', () {
      final session = LessonSession([
        ChoiceExercise(prompt: '', wordKeys: ['tere'], question: 'tere', options: ['a', 'hello'], correctIndex: 1, speakText: null),
      ], lessonId: 'x');
      session.submit(correct: true);
      expect(session.isFinished, isTrue);
      expect(session.xpEarned, 15);
      expect(session.accuracy, 1);
    });
  });

  group('progress', () {
    test('streak grows on consecutive days and resets after a gap', () {
      final p = Progress();
      p.markActive(DateTime(2026, 1, 1, 9));
      expect(p.streak, 1);
      p.markActive(DateTime(2026, 1, 1, 22));
      expect(p.streak, 1);
      p.markActive(DateTime(2026, 1, 2, 8));
      expect(p.streak, 2);
      expect(p.streakAt(DateTime(2026, 1, 3)), 2);
      expect(p.streakAt(DateTime(2026, 1, 4)), 0);
      p.markActive(DateTime(2026, 1, 5));
      expect(p.streak, 1);
    });

    test('word strength and due dates', () {
      final p = Progress();
      final t0 = DateTime(2026, 1, 1);
      p.recordAnswer('tere', correct: true, now: t0);
      expect(p.words['tere']!.strength, 1);
      expect(p.dueWords(t0), isEmpty);
      expect(p.dueWords(t0.add(const Duration(days: 1))), ['tere']);
      p.recordAnswer('tere', correct: false, now: t0);
      expect(p.words['tere']!.strength, 0);
      expect(p.dueWords(t0), ['tere']);
    });

    test('round-trips through JSON', () {
      final p = Progress(xp: 42, streak: 3)
        ..completedLessons.add('u1l1')
        ..lastActiveDay = DateTime(2026, 1, 2)
        ..recordAnswer('tere', correct: true, now: DateTime(2026, 1, 2, 10));
      final back = Progress.decode(p.encode());
      expect(back.xp, 42);
      expect(back.streak, 3);
      expect(back.completedLessons, {'u1l1'});
      expect(back.lastActiveDay, DateTime(2026, 1, 2));
      expect(back.words['tere']!.strength, 1);
    });
  });
}
