import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../theme.dart';

/// Plays Estonian text through the phone's TTS engine. Long-press for slow.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({super.key, required this.text, this.large = false});
  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final tts = AppScope.of(context).tts;
    return ListenableBuilder(
      listenable: tts,
      builder: (context, _) {
        final enabled = tts.isAvailable;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: enabled ? estonianBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: enabled ? () => tts.speak(text) : null,
              onLongPress: enabled ? () => tts.speak(text, slow: true) : null,
              child: Padding(
                padding: EdgeInsets.all(large ? 28 : 12),
                child: Icon(Icons.volume_up, color: Colors.white, size: large ? 48 : 28),
              ),
            ),
          ),
        );
      },
    );
  }
}
