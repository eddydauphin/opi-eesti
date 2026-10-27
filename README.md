# Õpi eesti – learn Estonian offline

A Duolingo-style Estonian course for Android. The whole course ships inside
the app, progress is saved on the phone, and nothing needs a connection, so
it works on a plane.

## What is in it

- Skill tree of units and lessons, unlocked in order.
- Exercise types: pick the translation, build a sentence from a word bank,
  type what you hear, match pairs. Mistakes come back at the end of the
  lesson until you get them right.
- XP, daily streak and a spaced-repetition review of words that are due.
- Estonian audio through the phone's own text-to-speech engine. Install the
  Estonian voice once while online (Settings › System › Languages ›
  Text-to-speech › Google Speech Services) and it then works offline.
- Grammar tips per unit.

## Course content

Everything the learner sees is in `assets/course/course.json`. Authors only
write words (`et`, `en`, optional `alt_en`) and sentences; the app generates
the exercises and picks distractors from the rest of the course.

To add a lesson: add an entry under a unit's `lessons`, give it a unique `id`,
at least four `words` and a few `sentences`. The tests check that every word
in a sentence has been taught in that unit or an earlier one.

## Getting the APK

Every push runs the GitHub Actions workflow, which lints, tests and builds a
release APK. Download it from the workflow run's **Artifacts** (file
`opi-eesti-apk`), copy it to the phone and open it. Android will ask you to
allow installing from unknown sources the first time.

Tag a commit `v0.1.0` and the same workflow attaches the APK to a GitHub
release.

## Developing

```
flutter pub get
flutter test
flutter run            # with a phone or emulator attached
flutter build apk      # build/app/outputs/flutter-apk/app-release.apk
```

Requires Flutter stable and the Android SDK.
