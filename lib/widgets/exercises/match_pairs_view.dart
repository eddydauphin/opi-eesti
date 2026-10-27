import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/exercise.dart';
import '../../theme.dart';

/// Two columns, Estonian on the left and English on the right. The learner
/// taps one from each column; the exercise completes itself when every pair
/// is matched and reports how many wrong taps were made.
class MatchPairsView extends StatefulWidget {
  const MatchPairsView({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  final MatchPairsExercise exercise;
  final void Function(int mistakes) onComplete;

  @override
  State<MatchPairsView> createState() => _MatchPairsViewState();
}

class _MatchPairsViewState extends State<MatchPairsView> {
  late final List<int> _leftOrder;
  late final List<int> _rightOrder;
  final Set<int> _matched = {};
  int? _selectedLeft;
  int? _selectedRight;
  int _mistakes = 0;
  bool _flashWrong = false;

  @override
  void initState() {
    super.initState();
    final n = widget.exercise.pairs.length;
    final rng = Random();
    _leftOrder = List.generate(n, (i) => i)..shuffle(rng);
    _rightOrder = List.generate(n, (i) => i)..shuffle(rng);
  }

  void _tapLeft(int pairIndex) {
    if (_matched.contains(pairIndex)) return;
    setState(() => _selectedLeft = _selectedLeft == pairIndex ? null : pairIndex);
    AppScope.of(context).tts.speak(widget.exercise.pairs[pairIndex].$1);
    _evaluate();
  }

  void _tapRight(int pairIndex) {
    if (_matched.contains(pairIndex)) return;
    setState(() => _selectedRight = _selectedRight == pairIndex ? null : pairIndex);
    _evaluate();
  }

  Future<void> _evaluate() async {
    final l = _selectedLeft;
    final r = _selectedRight;
    if (l == null || r == null) return;
    if (l == r) {
      setState(() {
        _matched.add(l);
        _selectedLeft = null;
        _selectedRight = null;
      });
      if (_matched.length == widget.exercise.pairs.length) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (mounted) widget.onComplete(_mistakes);
      }
    } else {
      setState(() {
        _mistakes += 1;
        _flashWrong = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) {
        setState(() {
          _flashWrong = false;
          _selectedLeft = null;
          _selectedRight = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.exercise.pairs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final i in _leftOrder)
                _PairTile(
                  text: pairs[i].$1,
                  matched: _matched.contains(i),
                  selected: _selectedLeft == i,
                  wrong: _flashWrong && _selectedLeft == i,
                  onTap: () => _tapLeft(i),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              for (final i in _rightOrder)
                _PairTile(
                  text: pairs[i].$2,
                  matched: _matched.contains(i),
                  selected: _selectedRight == i,
                  wrong: _flashWrong && _selectedRight == i,
                  onTap: () => _tapRight(i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PairTile extends StatelessWidget {
  const _PairTile({
    required this.text,
    required this.matched,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  final String text;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = wrong
        ? errorRed
        : matched
            ? successGreen
            : selected
                ? estonianBlue
                : Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: matched ? successGreen.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: matched ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: matched ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
