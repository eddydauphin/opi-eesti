import 'dart:convert';

/// Spaced-repetition state of one vocabulary item.
class WordProgress {
  WordProgress({this.strength = 0, this.lastSeen});

  /// 0 (new or forgotten) to [maxStrength] (well known).
  int strength;
  DateTime? lastSeen;

  static const maxStrength = 5;

  /// How long a word at a given strength stays "fresh" before it is due.
  static const reviewIntervals = [
    Duration.zero,
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];

  bool isDue(DateTime now) {
    final seen = lastSeen;
    if (seen == null) return true;
    return now.difference(seen) >= reviewIntervals[strength];
  }

  Map<String, dynamic> toJson() => {
        's': strength,
        if (lastSeen != null) 't': lastSeen!.toIso8601String(),
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) => WordProgress(
        strength: (json['s'] as num?)?.toInt() ?? 0,
        lastSeen: json['t'] == null ? null : DateTime.parse(json['t'] as String),
      );
}

/// Everything the app remembers about the learner. Stored locally as JSON.
class Progress {
  Progress({
    Set<String>? completedLessons,
    Map<String, WordProgress>? words,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDay,
  })  : completedLessons = completedLessons ?? {},
        words = words ?? {};

  final Set<String> completedLessons;
  final Map<String, WordProgress> words;
  int xp;
  int streak;

  /// Calendar day (local time, midnight) of the last completed session.
  DateTime? lastActiveDay;

  static DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  bool isLessonDone(String id) => completedLessons.contains(id);

  /// The streak as it should be displayed: it drops to zero if the learner
  /// missed a whole day.
  int streakAt(DateTime now) {
    final last = lastActiveDay;
    if (last == null) return 0;
    final gap = dayOf(now).difference(last).inDays;
    return gap <= 1 ? streak : 0;
  }

  /// Records that a session was completed now, extending or resetting the streak.
  void markActive(DateTime now) {
    final today = dayOf(now);
    final last = lastActiveDay;
    if (last == null) {
      streak = 1;
    } else {
      final gap = today.difference(last).inDays;
      if (gap == 1) {
        streak += 1;
      } else if (gap > 1) {
        streak = 1;
      }
    }
    lastActiveDay = today;
  }

  void recordAnswer(String wordKey, {required bool correct, required DateTime now}) {
    final w = words.putIfAbsent(wordKey, WordProgress.new);
    if (correct) {
      w.strength = (w.strength + 1).clamp(0, WordProgress.maxStrength);
    } else {
      w.strength = (w.strength - 2).clamp(0, WordProgress.maxStrength);
    }
    w.lastSeen = now;
  }

  /// Keys of learned words that are due for review, weakest first.
  List<String> dueWords(DateTime now) {
    final due = words.entries.where((e) => e.value.isDue(now)).toList()
      ..sort((a, b) {
        final byStrength = a.value.strength.compareTo(b.value.strength);
        if (byStrength != 0) return byStrength;
        final ta = a.value.lastSeen ?? DateTime(2000);
        final tb = b.value.lastSeen ?? DateTime(2000);
        return ta.compareTo(tb);
      });
    return [for (final e in due) e.key];
  }

  Map<String, dynamic> toJson() => {
        'lessons': completedLessons.toList(),
        'words': {for (final e in words.entries) e.key: e.value.toJson()},
        'xp': xp,
        'streak': streak,
        if (lastActiveDay != null) 'lastActiveDay': lastActiveDay!.toIso8601String(),
      };

  String encode() => jsonEncode(toJson());

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        completedLessons: ((json['lessons'] as List?) ?? const []).cast<String>().toSet(),
        words: {
          for (final e in ((json['words'] as Map?) ?? const {}).entries)
            e.key as String: WordProgress.fromJson(e.value as Map<String, dynamic>),
        },
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        lastActiveDay: json['lastActiveDay'] == null
            ? null
            : DateTime.parse(json['lastActiveDay'] as String),
      );

  factory Progress.decode(String raw) =>
      Progress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
