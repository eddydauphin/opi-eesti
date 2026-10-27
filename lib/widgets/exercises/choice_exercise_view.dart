import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../theme.dart';
import 'speaker_button.dart';

class ChoiceExerciseView extends StatelessWidget {
  const ChoiceExerciseView({
    super.key,
    required this.exercise,
    required this.selected,
    required this.onSelect,
    required this.locked,
  });

  final ChoiceExercise exercise;
  final int? selected;
  final ValueChanged<int> onSelect;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (exercise.speakText != null) SpeakerButton(text: exercise.speakText!),
            Expanded(
              child: Text(exercise.question,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < exercise.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              key: ValueKey('option_$i'),
              text: exercise.options[i],
              selected: selected == i,
              onTap: locked ? null : () => onSelect(i),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({super.key, required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? estonianBlue.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? estonianBlue : Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
