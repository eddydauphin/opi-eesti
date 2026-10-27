import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opi_eesti/models/course.dart';
import 'package:opi_eesti/services/text_utils.dart';

/// Guards the bundled course against authoring mistakes.
void main() {
  late Course course;

  setUpAll(() {
    final raw = File('assets/course/course.json').readAsStringSync();
    course = Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('course has units and lessons', () {
    expect(course.units, isNotEmpty);
    expect(course.lessons.length, greaterThanOrEqualTo(4));
  });

  test('unit and lesson ids are unique', () {
    final unitIds = course.units.map((u) => u.id).toList();
    expect(unitIds.toSet().length, unitIds.length);
    final lessonIds = course.lessons.map((l) => l.id).toList();
    expect(lessonIds.toSet().length, lessonIds.length);
  });

  test('every lesson has enough words to build exercises', () {
    for (final l in course.lessons) {
      expect(l.words.length, greaterThanOrEqualTo(4), reason: 'lesson ${l.id}');
      expect(l.sentences, isNotEmpty, reason: 'lesson ${l.id}');
    }
  });

  test('words are non-empty and not duplicated inside a lesson', () {
    for (final l in course.lessons) {
      final ets = l.words.map((w) => w.et).toList();
      expect(ets.toSet().length, ets.length, reason: 'duplicate in ${l.id}');
      for (final w in l.words) {
        expect(w.et.trim(), isNotEmpty);
      }
    }
  });

  test('every word, sentence, subtitle and tip exists in every learner language', () {
    expect(course.learnerLanguages, containsAll(['en', 'fr', 'es']));
    for (final lang in course.learnerLanguages) {
      for (final u in course.units) {
        expect(u.subtitle.of(lang).trim(), isNotEmpty, reason: '${u.id} subtitle $lang');
        if (!u.tip.isEmpty) {
          expect(u.tip.of(lang), isNot(u.tip.of(lang == 'en' ? 'fr' : 'en')),
              reason: '${u.id} tip not translated to $lang');
        }
      }
      for (final l in course.lessons) {
        for (final w in l.words) {
          expect(w.translations[lang], isNotNull, reason: '"${w.et}" has no $lang');
          expect(w.translations[lang]!.first.trim(), isNotEmpty);
        }
        for (final s in l.sentences) {
          expect(s.translations[lang], isNotNull, reason: '"${s.et}" has no $lang');
          expect(s.translations[lang]!.first.trim(), isNotEmpty);
        }
      }
    }
  });

  test('match-pair meanings are distinct within a lesson in every language', () {
    for (final lang in course.learnerLanguages) {
      for (final l in course.lessons) {
        final meanings = l.words.map((w) => w.meaning(lang)).toList();
        expect(meanings.toSet().length, meanings.length,
            reason: 'duplicate $lang meaning in ${l.id}: $meanings');
      }
    }
  });

  test('every sentence word is introduced in or before its unit', () {
    final known = <String>{};
    for (final unit in course.units) {
      for (final w in unit.words) {
        known.addAll(tokenize(w.et).map((t) => t.toLowerCase()));
      }
      // Names are allowed; everything else must be vocabulary.
      const names = {'eddy', 'anna', 'mari'};
      for (final lesson in unit.lessons) {
        for (final s in lesson.sentences) {
          for (final tok in tokenize(s.et)) {
            final t = tok.toLowerCase();
            expect(known.contains(t) || names.contains(t), isTrue,
                reason: '"$tok" in "${s.et}" (${lesson.id}) is not taught');
          }
        }
      }
    }
  });
}
