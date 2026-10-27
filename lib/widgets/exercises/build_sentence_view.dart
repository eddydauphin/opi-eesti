import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../theme.dart';
import 'speaker_button.dart';

/// Word-bank exercise: tap tokens to build the translation.
class BuildSentenceView extends StatelessWidget {
  const BuildSentenceView({
    super.key,
    required this.exercise,
    required this.chosen,
    required this.onChosenChanged,
    required this.locked,
  });

  final BuildSentenceExercise exercise;

  /// Indices into [exercise.bank], in the order they were tapped.
  final List<int> chosen;
  final ValueChanged<List<int>> onChosenChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.speakText != null) SpeakerButton(text: exercise.speakText!),
            Expanded(
              child: Text(exercise.source,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 2),
              top: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in chosen)
                _Chip(
                  text: exercise.bank[i],
                  onTap: locked ? null : () => onChosenChanged([...chosen]..remove(i)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < exercise.bank.length; i++)
              chosen.contains(i)
                  ? _Chip(text: exercise.bank[i], placeholder: true)
                  : _Chip(
                      text: exercise.bank[i],
                      onTap: locked ? null : () => onChosenChanged([...chosen, i]),
                    ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.onTap, this.placeholder = false});
  final String text;
  final VoidCallback? onTap;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: placeholder ? Colors.grey.shade200 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: placeholder ? Colors.grey.shade200 : Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: placeholder ? Colors.transparent : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown in the result sheet when a word-bank answer was wrong.
Color resultColor(bool correct) => correct ? successGreen : errorRed;
