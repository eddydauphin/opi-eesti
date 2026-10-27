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
        expect(w.en.trim(), isNotEmpty);
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
