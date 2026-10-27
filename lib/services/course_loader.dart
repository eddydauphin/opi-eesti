import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/course.dart';

const courseAssetPath = 'assets/course/course.json';

/// Loads the bundled course. The JSON ships inside the APK, so this works
/// with no connection.
Future<Course> loadCourse({AssetBundle? bundle}) async {
  final raw = await (bundle ?? rootBundle).loadString(courseAssetPath);
  return Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
