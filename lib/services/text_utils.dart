/// Helpers for comparing learner answers with expected answers.
///
/// Comparison ignores case, punctuation and extra spaces but keeps the
/// Estonian letters õ, ä, ö, ü, š and ž, because those change meaning.
String normalizeAnswer(String s) {
  final lower = s.toLowerCase();
  final stripped = lower.replaceAll(RegExp(r"[^\p{L}\p{N}\s']", unicode: true), ' ');
  return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool answersMatch(String given, Iterable<String> accepted) {
  final g = normalizeAnswer(given);
  return accepted.any((a) => normalizeAnswer(a) == g);
}

/// Splits a sentence into word-bank tokens, dropping punctuation.
List<String> tokenize(String sentence) {
  return sentence
      .replaceAll(RegExp(r"[^\p{L}\p{N}\s'-]", unicode: true), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
}
