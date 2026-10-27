import 'package:flutter/material.dart';

import '../app_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: scope.tts,
        builder: (context, _) {
          final available = scope.tts.isAvailable;
          return ListView(
            children: [
              ListTile(
                leading: Icon(available ? Icons.volume_up : Icons.volume_off,
                    color: available ? Colors.green : Colors.orange),
                title: const Text('Estonian voice'),
                subtitle: Text(available
                    ? 'Installed. Listening exercises work offline.'
                    : 'Not installed. On the phone go to Settings › System › '
                        'Languages › Text-to-speech, open Google Speech Services '
                        'and install the Estonian voice while online. '
                        'Until then listening exercises are skipped.'),
                trailing: available
                    ? TextButton(
                        onPressed: () => scope.tts.speak('Tere! Kuidas läheb?'),
                        child: const Text('Test'),
                      )
                    : TextButton(
                        onPressed: scope.tts.init,
                        child: const Text('Retry'),
                      ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Reset progress'),
                subtitle: const Text('Clears lessons, XP, streak and word strengths.'),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset progress?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                      ],
                    ),
                  );
                  if (ok == true) await scope.progress.reset();
                },
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                subtitle: Text('Õpi eesti keelt. All lessons are stored on the phone; '
                    'no internet connection is needed.'),
              ),
            ],
          );
        },
      ),
    );
  }
}
