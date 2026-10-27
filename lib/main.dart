import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'models/course.dart';
import 'screens/home_screen.dart';
import 'services/course_loader.dart';
import 'services/progress_store.dart';
import 'services/tts_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpiEestiApp());
}

class OpiEestiApp extends StatefulWidget {
  const OpiEestiApp({super.key, this.course, this.progress, this.tts});

  /// Injectable for tests; the app loads its own when these are null.
  final Course? course;
  final ProgressStore? progress;
  final TtsService? tts;

  @override
  State<OpiEestiApp> createState() => _OpiEestiAppState();
}

class _OpiEestiAppState extends State<OpiEestiApp> {
  late final Future<(Course, ProgressStore, TtsService)> _boot = _load();

  Future<(Course, ProgressStore, TtsService)> _load() async {
    final course = widget.course ?? await loadCourse();
    final progress = widget.progress ?? await ProgressStore.load();
    final tts = widget.tts ?? TtsService();
    // Do not block startup on the TTS engine; it reports availability later.
    tts.init();
    return (course, progress, tts);
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
        return AppScope(
          course: data.$1,
          progress: data.$2,
          tts: data.$3,
          child: MaterialApp(
            title: 'Õpi eesti',
            theme: buildTheme(),
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
