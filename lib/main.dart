import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'l10n/strings.dart';
import 'models/course.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'services/course_loader.dart';
import 'services/progress_store.dart';
import 'services/settings_store.dart';
import 'services/tts_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpiEestiApp());
}

class OpiEestiApp extends StatefulWidget {
  const OpiEestiApp({super.key, this.course, this.progress, this.settings, this.tts});

  /// Injectable for tests; the app loads its own when these are null.
  final Course? course;
  final ProgressStore? progress;
  final SettingsStore? settings;
  final TtsService? tts;

  @override
  State<OpiEestiApp> createState() => _OpiEestiAppState();
}

class _OpiEestiAppState extends State<OpiEestiApp> {
  late final Future<_Boot> _boot = _load();

  Future<_Boot> _load() async {
    final course = widget.course ?? await loadCourse();
    final progress = widget.progress ?? await ProgressStore.load();
    final settings = widget.settings ?? await SettingsStore.load();
    final tts = widget.tts ?? TtsService();
    // Do not block startup on the TTS engine; it reports availability later.
    tts.init();
    return _Boot(course, progress, settings, tts);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _boot,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return MaterialApp(
            theme: buildTheme(),
            debugShowCheckedModeBanner: false,
            home: const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        // AppScope sits above the MaterialApp so every pushed route can see it.
        // Rebuilding on settings changes switches the whole UI language.
        return ListenableBuilder(
          listenable: data.settings,
          builder: (context, _) {
            final lang = data.settings.language;
            return AppScope(
              course: data.course,
              progress: data.progress,
              settings: data.settings,
              tts: data.tts,
              child: MaterialApp(
                title: 'Õpi eesti',
                theme: buildTheme(),
                debugShowCheckedModeBanner: false,
                locale: Locale(lang ?? 'en'),
                supportedLocales: [for (final l in Strings.supported) Locale(l)],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: lang == null ? const LanguageScreen(firstRun: true) : const HomeScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

class _Boot {
  _Boot(this.course, this.progress, this.settings, this.tts);
  final Course course;
  final ProgressStore progress;
  final SettingsStore settings;
  final TtsService tts;
}
