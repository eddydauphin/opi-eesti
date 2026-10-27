/// Course content model. The whole course ships inside the app as a JSON
/// asset, so everything here works with no network connection.
class Course {
  Course({required this.title, required this.language, required this.units});

  final String title;
  final String language;
  final List<Unit> units;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        title: json['title'] as String,
        language: json['language'] as String,
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

class Unit {
  Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
    this.tip,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? tip;
  final List<Lesson> lessons;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        tip: json['tip'] as String?,
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
    this.tip,
  });

  final String id;
  final String title;
  final String? tip;
  final List<Word> words;
  final List<Sentence> sentences;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        tip: json['tip'] as String?,
        words: (json['words'] as List)
            .map((w) => Word.fromJson(w as Map<String, dynamic>))
            .toList(),
        sentences: (json['sentences'] as List? ?? const [])
            .map((s) => Sentence.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// A vocabulary item: one Estonian word or short phrase and its meaning.
class Word {
  Word({required this.et, required this.en, this.altEn = const []});

  final String et;
  final String en;
  final List<String> altEn;

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        et: json['et'] as String,
        en: json['en'] as String,
        altEn: (json['alt_en'] as List? ?? const []).cast<String>(),
      );

  List<String> get acceptedEn => [en, ...altEn];
}

/// A full sentence used for translation and listening exercises.
class Sentence {
  Sentence({required this.et, required this.en, this.altEn = const []});

  final String et;
  final String en;
  final List<String> altEn;

  factory Sentence.fromJson(Map<String, dynamic> json) => Sentence(
        et: json['et'] as String,
        en: json['en'] as String,
        altEn: (json['alt_en'] as List? ?? const []).cast<String>(),
      );

  List<String> get acceptedEn => [en, ...altEn];
}
