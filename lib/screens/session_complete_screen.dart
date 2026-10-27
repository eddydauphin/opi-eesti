import 'package:flutter/material.dart';

import '../theme.dart';

/// Shown when a lesson or review ends.
class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({
    super.key,
    required this.title,
    required this.xpEarned,
    required this.accuracy,
    required this.streak,
  });

  final String title;
  final int xpEarned;
  final double accuracy;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final pct = (accuracy * 100).round();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.emoji_events, size: 96, color: Colors.amber),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Tubli! (Well done!)', style: TextStyle(fontSize: 18, color: Colors.black54)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Badge(label: 'XP', value: '+$xpEarned', color: Colors.amber.shade700),
                  _Badge(label: 'Accuracy', value: '$pct%', color: successGreen),
                  _Badge(label: 'Streak', value: '$streak', color: Colors.orange),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
