import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../theme.dart';

/// Lets the learner pick the language they learn Estonian from. Shown on
/// first launch and reachable again from Settings.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, this.firstRun = false});

  final bool firstRun;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final current = scope.settings.language;
    return Scaffold(
      appBar: firstRun ? null : AppBar(title: Text(scope.strings.language)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (firstRun) ...[
                const SizedBox(height: 32),
                const Center(child: Icon(Icons.language, size: 72, color: estonianBlue)),
                const SizedBox(height: 16),
                const Text('Õpi eesti keelt',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                // Shown in every language on purpose: no language is chosen yet.
                Text(
                  [for (final l in Strings.supported) Strings.of(l).appSubtitle].join(' · '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 40),
              ],
              for (final l in Strings.supported)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LanguageTile(
                    code: l,
                    selected: current == l,
                    onTap: () async {
                      await scope.settings.setLanguage(l);
                      if (!firstRun && context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                firstRun
                    ? [for (final l in Strings.supported) Strings.of(l).chooseLanguage].join('   ')
                    : scope.strings.chooseLanguageBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.code, required this.selected, required this.onTap});
  final String code;
  final bool selected;
  final VoidCallback onTap;

  static const _flags = {'en': '🇬🇧', 'fr': '🇫🇷', 'es': '🇪🇸'};

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? estonianBlue.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: ValueKey('lang_$code'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? estonianBlue : Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(_flags[code] ?? '', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(Strings.languageNames[code] ?? code,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              if (selected) const Icon(Icons.check_circle, color: estonianBlue),
            ],
          ),
        ),
      ),
    );
  }
}
