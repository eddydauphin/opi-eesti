import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/course.dart';
import '../models/exercise.dart';
import '../services/exercise_generator.dart';
import '../services/lesson_session.dart';
import '../theme.dart';
import '../widgets/exercises/build_sentence_view.dart';
import '../widgets/exercises/choice_exercise_view.dart';
import '../widgets/exercises/listen_type_view.dart';
import '../widgets/exercises/match_pairs_view.dart';
import 'session_complete_screen.dart';

/// Runs one lesson or one review session, exercise by exercise.
class LessonScreen extends StatefulWidget {
  const LessonScreen._({this.lesson, this.reviewWords});

  factory LessonScreen.lesson(Lesson lesson) => LessonScreen._(lesson: lesson);
  factory LessonScreen.review(List<String> words) => LessonScreen._(reviewWords: words);

  final Lesson? lesson;
  final List<String>? reviewWords;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  LessonSession? _session;

  // Per-exercise answer state.
  int? _choiceSelected;
  List<int> _bankChosen = const [];
  final _typed = TextEditingController();

  /// Set after Check: whether the current answer was right.
  bool? _result;
  bool _spokeCurrent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_session != null) return;
    final scope = AppScope.of(context);
    final gen = ExerciseGenerator(scope.course, lang: scope.lang);
    final lesson = widget.lesson;
    final exercises = lesson != null
        ? gen.forLesson(lesson, includeListening: scope.tts.isAvailable)
        : gen.forReview(widget.reviewWords ?? const []);
    _session = LessonSession(exercises, lessonId: lesson?.id);
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  void _resetAnswerState() {
    _choiceSelected = null;
    _bankChosen = const [];
    _typed.clear();
    _result = null;
    _spokeCurrent = false;
  }

  bool get _canCheck {
    final ex = _session?.current;
    return switch (ex) {
      ChoiceExercise() => _choiceSelected != null,
      BuildSentenceExercise() => _bankChosen.isNotEmpty,
      ListenTypeExercise() => _typed.text.trim().isNotEmpty,
      _ => false,
    };
  }

  void _check() {
    final session = _session!;
    final ex = session.current!;
    final correct = switch (ex) {
      ChoiceExercise() => LessonSession.checkChoice(ex, _choiceSelected),
      BuildSentenceExercise() =>
        LessonSession.checkBuild(ex, [for (final i in _bankChosen) ex.bank[i]]),
      ListenTypeExercise() => LessonSession.checkTyped(ex, _typed.text),
      MatchPairsExercise() => true,
    };
    setState(() => _result = correct);
  }

  void _continue() {
    final session = _session!;
    session.submit(correct: _result ?? false);
    _afterSubmit();
  }

  void _onPairsComplete(int mistakes) {
    final session = _session!;
    // Matching is self-correcting: count it as right, but a sloppy round
    // still counts as mistakes for the score.
    session.submit(correct: mistakes == 0);
    if (mistakes > 0) {
      // Do not make the learner redo the matching; take it back off the queue.
      session.skipMatchRepeat();
    }
    _afterSubmit();
  }

  Future<void> _afterSubmit() async {
    final session = _session!;
    if (session.isFinished) {
      await _finish();
      return;
    }
    setState(_resetAnswerState);
  }

  Future<void> _finish() async {
    final session = _session!;
    final scope = AppScope.of(context);
    await scope.progress.completeSession(
      lessonId: session.lessonId,
      xpEarned: session.xpEarned,
      wordResults: session.wordResults,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => SessionCompleteScreen(
        title: widget.lesson?.title ?? scope.strings.reviewComplete,
        xpEarned: session.xpEarned,
        accuracy: session.accuracy,
        streak: scope.progress.streak,
      ),
    ));
  }

  void _skipListening() {
    setState(() {
      _session!.skipListening();
      _resetAnswerState();
    });
    if (_session!.isFinished) _finish();
  }

  Future<void> _quit() async {
    final quit = await _confirmQuit();
    if (!quit || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmQuit() async {
    final t = AppScope.of(context).strings;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.quitTitle),
        content: Text(t.quitBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.keepGoing)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.quit)),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final session = _session!;
    final ex = session.current;
    if (ex == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_spokeCurrent) {
      _spokeCurrent = true;
      final text = switch (ex) {
        ChoiceExercise(:final speakText) => speakText,
        ListenTypeExercise(:final speakText) => speakText,
        _ => null,
      };
      if (text != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) AppScope.of(context).tts.speak(text);
        });
      }
    }
    final locked = _result != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _quit,
          ),
          title: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: session.progress,
              minHeight: 14,
              backgroundColor: Colors.grey.shade300,
              color: successGreen,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.prompt,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 20),
                      _exerciseView(ex, locked),
                    ],
                  ),
                ),
              ),
              if (ex is! MatchPairsExercise) _bottomBar(ex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exerciseView(Exercise ex, bool locked) {
    return switch (ex) {
      ChoiceExercise() => ChoiceExerciseView(
          exercise: ex,
          selected: _choiceSelected,
          locked: locked,
          onSelect: (i) => setState(() => _choiceSelected = i),
        ),
      BuildSentenceExercise() => BuildSentenceView(
          exercise: ex,
          chosen: _bankChosen,
          locked: locked,
          onChosenChanged: (c) => setState(() => _bankChosen = c),
        ),
      ListenTypeExercise() => ListenTypeView(
          exercise: ex,
          controller: _typed,
          locked: locked,
          onSkipListening: _skipListening,
        ),
      MatchPairsExercise() => MatchPairsView(
          key: ValueKey(identityHashCode(ex)),
          exercise: ex,
          onComplete: _onPairsComplete,
        ),
    };
  }

  Widget _bottomBar(Exercise ex) {
    final t = AppScope.of(context).strings;
    final result = _result;
    if (result == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: ListenableBuilder(
          listenable: _typed,
          builder: (context, _) => FilledButton(
            onPressed: _canCheck ? _check : null,
            child: Text(t.check),
          ),
        ),
      );
    }
    final correctText = switch (ex) {
      ChoiceExercise() => ex.options[ex.correctIndex],
      BuildSentenceExercise() => ex.acceptedAnswers.first,
      ListenTypeExercise() => '${ex.speakText}\n(${ex.translation})',
      MatchPairsExercise() => '',
    };
    final color = result ? successGreen : errorRed;
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result ? Icons.check_circle : Icons.cancel, color: color, size: 30),
              const SizedBox(width: 8),
              Text(result ? t.correct : t.notQuite,
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          if (!result || ex is ListenTypeExercise) ...[
            const SizedBox(height: 8),
            Text(result ? t.meaning : t.correctAnswer,
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            Text(result && ex is ListenTypeExercise ? ex.translation : correctText,
                style: const TextStyle(fontSize: 17)),
          ],
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: _continue,
            child: Text(t.continueLabel),
          ),
        ],
      ),
    );
  }
}
