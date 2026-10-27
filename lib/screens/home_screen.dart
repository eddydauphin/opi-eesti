import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/course.dart';
import '../theme.dart';
import 'lesson_screen.dart';
import 'settings_screen.dart';

/// The skill tree: units with their lessons, plus streak, XP and review.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final course = scope.course;
    return ListenableBuilder(
      listenable: scope.progress,
      builder: (context, _) {
        final progress = scope.progress;
        final lessons = course.lessons;
        final due = progress.dueWords;
        final t = scope.strings;
        final lang = scope.lang;
        return Scaffold(
          appBar: AppBar(
            title: Text(t.appTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              _Stat(icon: Icons.local_fire_department, color: Colors.orange, value: '${progress.streak}'),
              _Stat(icon: Icons.bolt, color: Colors.amber.shade700, value: '${progress.xp} XP'),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: t.settings,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (due.isNotEmpty)
                _ReviewCard(
                  title: t.review,
                  subtitle: t.wordsDue(due.length),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LessonScreen.review(due)),
                  ),
                ),
              for (final unit in course.units)
                _UnitSection(
                  unit: unit,
                  lang: lang,
                  tipsLabel: t.tips,
                  lessonMeta: t.lessonMeta,
                  isUnlocked: (lesson) {
                    final i = lessons.indexWhere((l) => l.id == lesson.id);
                    return i == 0 || progress.isLessonDone(lessons[i - 1].id);
                  },
                  isDone: (lesson) => progress.isLessonDone(lesson.id),
                  onOpen: (lesson) => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LessonScreen.lesson(lesson)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value});
  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: estonianBlue,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.refresh, color: Colors.white, size: 32),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }
}

class _UnitSection extends StatelessWidget {
  const _UnitSection({
    required this.unit,
    required this.lang,
    required this.tipsLabel,
    required this.lessonMeta,
    required this.isUnlocked,
    required this.isDone,
    required this.onOpen,
  });

  final Unit unit;
  final String lang;
  final String tipsLabel;
  final String Function(int words, int sentences) lessonMeta;
  final bool Function(Lesson) isUnlocked;
  final bool Function(Lesson) isDone;
  final void Function(Lesson) onOpen;

  @override
  Widget build(BuildContext context) {
    final doneCount = unit.lessons.where(isDone).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(unit.subtitle.of(lang), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                if (!unit.tip.isEmpty)
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.white),
                    tooltip: tipsLabel,
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => _TipSheet(title: unit.title, tip: unit.tip.of(lang)),
                    ),
                  ),
                Text('$doneCount/${unit.lessons.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final lesson in unit.lessons)
            _LessonTile(
              lesson: lesson,
              meta: lessonMeta(lesson.words.length, lesson.sentences.length),
              unlocked: isUnlocked(lesson),
              done: isDone(lesson),
              onTap: () => onOpen(lesson),
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.meta,
    required this.unlocked,
    required this.done,
    required this.onTap,
  });

  final Lesson lesson;
  final String meta;
  final bool unlocked;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? successGreen
        : unlocked
            ? estonianBlue
            : Colors.grey.shade400;
    final icon = done
        ? Icons.check
        : unlocked
            ? Icons.star
            : Icons.lock;
    return ListTile(
      enabled: unlocked,
      onTap: unlocked ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
      title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      subtitle: Text(meta),
      trailing: unlocked ? const Icon(Icons.chevron_right) : null,
    );
  }
}

class _TipSheet extends StatelessWidget {
  const _TipSheet({required this.title, required this.tip});
  final String title;
  final String tip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(tip, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
