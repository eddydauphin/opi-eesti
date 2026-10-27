import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = scope.strings;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListenableBuilder(
        listenable: Listenable.merge([scope.tts, scope.settings]),
        builder: (context, _) {
          final available = scope.tts.isAvailable;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(t.language),
                subtitle: Text(Strings.languageNames[scope.lang] ?? scope.lang),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LanguageScreen()),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(available ? Icons.volume_up : Icons.volume_off,
                    color: available ? Colors.green : Colors.orange),
                title: Text(t.estonianVoice),
                subtitle: Text(available ? t.voiceInstalled : t.voiceMissing),
                trailing: available
                    ? TextButton(
                        onPressed: () => scope.tts.speak('Tere! Kuidas läheb?'),
                        child: Text(t.test),
                      )
                    : TextButton(
                        onPressed: scope.tts.init,
                        child: Text(t.retry),
                      ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(t.resetProgress),
                subtitle: Text(t.resetProgressBody),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t.resetConfirm),
                      content: Text(t.cannotUndo),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.reset)),
                      ],
                    ),
                  );
                  if (ok == true) await scope.progress.reset();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(t.about),
                subtitle: Text(t.aboutBody),
              ),
            ],
          );
        },
      ),
    );
  }
}
