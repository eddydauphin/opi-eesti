/// Course content model. The whole course ships inside the app as a JSON
/// asset, so everything here works with no network connection.
///
/// Estonian is always the target language. Every word and sentence carries
/// translations in each supported learner language ("en", "fr", "es").
class Course {
  Course({
    required this.title,
    required this.language,
    required this.learnerLanguages,
    required this.units,
  });

  final String title;
  final String language;
  final List<String> learnerLanguages;
  final List<Unit> units;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        title: json['title'] as String,
        language: json['language'] as String,
        learnerLanguages:
            ((json['learner_languages'] as List?) ?? const ['en']).cast<String>(),
        units: (json['units'] as List)
            .map((u) => Unit.fromJson(u as Map<String, dynamic>))
            .toList(),
      );

  /// All lessons in course order.
  List<Lesson> get lessons => [for (final u in units) ...u.lessons];

  /// Every vocabulary item in the course, in course order.
  List<Word> get allWords => [for (final l in lessons) ...l.words];

  Word? wordByEt(String et) {
    for (final w in allWords) {
      if (w.et == et) return w;
    }
    return null;
  }

  Lesson? lessonById(String id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  Unit? unitOfLesson(String lessonId) {
    for (final u in units) {
      if (u.lessons.any((l) => l.id == lessonId)) return u;
    }
    return null;
  }
}

/// Text that exists in each learner language, e.g. a unit subtitle or tip.
class LocalizedText {
  LocalizedText(this._byLang);

  final Map<String, String> _byLang;

  /// Accepts either a plain string (treated as English) or a language map.
  factory LocalizedText.fromJson(Object? json) {
    if (json == null) return LocalizedText(const {});
    if (json is String) return LocalizedText({'en': json});
    return LocalizedText((json as Map).cast<String, String>());
  }

  bool get isEmpty => _byLang.isEmpty;

  String of(String lang) => _byLang[lang] ?? _byLang['en'] ?? _byLang.values.firstOrNull ?? '';
}

class Unit {
  Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
    required this.tip,
  });

  final String id;
  final String title;
  final LocalizedText subtitle;
  final LocalizedText tip;
  final List<Lesson> lessons;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: LocalizedText.fromJson(json['subtitle']),
        tip: LocalizedText.fromJson(json['tip']),
        lessons: (json['lessons'] as List)
            .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
            .toList(),
      );

  List<Word> get words => [for (final l in lessons) ...l.words];
}

class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.words,
    required this.sentences,
    required this.tip,
  });

  final String id;
  final String title;
  final LocalizedText tip;
  final List<Word> words;
  final List<Sentence> sentences;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        tip: LocalizedText.fromJson(json['tip']),
        words: (json['words'] as List)
            .map((w) => Word.fromJson(w as Map<String, dynamic>))
            .toList(),
        sentences: (json['sentences'] as List? ?? const [])
            .map((s) => Sentence.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// Parses the `en` / `alt_en`, `fr` / `alt_fr`, ... keys of a content entry
/// into a map from language to accepted translations, primary first.
Map<String, List<String>> _translationsFromJson(Map<String, dynamic> json) {
  final out = <String, List<String>>{};
  for (final e in json.entries) {
    if (e.key == 'et' || e.key.startsWith('alt_')) continue;
    if (e.value is! String) continue;
    final alts = (json['alt_${e.key}'] as List? ?? const []).cast<String>();
    out[e.key] = [e.value as String, ...alts];
  }
  return out;
}

/// A vocabulary item: one Estonian word or short phrase and its meanings.
class Word {
  Word({required this.et, required this.translations});

  final String et;

  /// Language code to accepted translations, primary first.
  final Map<String, List<String>> translations;

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        et: json['et'] as String,
        translations: _translationsFromJson(json),
      );

  /// The main translation shown to the learner.
  String meaning(String lang) =>
      translations[lang]?.first ?? translations['en']?.first ?? et;

  List<String> accepted(String lang) =>
      translations[lang] ?? translations['en'] ?? const [];
}

/// A full sentence used for translation and listening exercises.
class Sentence {
  Sentence({required this.et, required this.translations});

  final String et;
  final Map<String, List<String>> translations;

  factory Sentence.fromJson(Map<String, dynamic> json) => Sentence(
        et: json['et'] as String,
        translations: _translationsFromJson(json),
      );

  String meaning(String lang) =>
      translations[lang]?.first ?? translations['en']?.first ?? et;

  List<String> accepted(String lang) =>
      translations[lang] ?? translations['en'] ?? const [];
}
