import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opi_eesti/main.dart';
import 'package:opi_eesti/models/course.dart';
import 'package:opi_eesti/services/progress_store.dart';
import 'package:opi_eesti/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Course course;

  setUpAll(() {
    final raw = File('assets/course/course.json').readAsStringSync();
    course = Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home shows units and opens the first lesson', (tester) async {
    await tester.pumpWidget(OpiEestiApp(
      course: course,
      progress: ProgressStore(),
      tts: TtsService(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tervitused'), findsOneWidget);
    expect(find.text('Tere!'), findsOneWidget);

    await tester.tap(find.text('Tere!'));
    await tester.pumpAndSettle();

    // First exercise is a multiple-choice introduction of a new word.
    expect(find.text('What does this mean?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Check'), findsOneWidget);
  });

  testWidgets('answering a choice shows feedback', (tester) async {
    await tester.pumpWidget(OpiEestiApp(
      course: course,
      progress: ProgressStore(),
      tts: TtsService(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tere!'));
    await tester.pumpAndSettle();

    // Tap the first option, then Check.
    await tester.tap(find.byKey(const ValueKey('option_0')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Check'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });
}
