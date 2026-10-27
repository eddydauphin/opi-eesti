import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/exercise.dart';
import 'speaker_button.dart';

/// Hear Estonian, type it back.
class ListenTypeView extends StatelessWidget {
  const ListenTypeView({
    super.key,
    required this.exercise,
    required this.controller,
    required this.locked,
    required this.onSkipListening,
  });

  final ListenTypeExercise exercise;
  final TextEditingController controller;
  final bool locked;
  final VoidCallback onSkipListening;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: SpeakerButton(text: exercise.speakText, large: true)),
        const SizedBox(height: 8),
        Center(
          child: Text(t.tapToListen, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          enabled: !locked,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            hintText: t.typeInEstonian,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: locked ? null : onSkipListening,
            child: Text(t.cantListenNow),
          ),
        ),
      ],
    );
  }
}
