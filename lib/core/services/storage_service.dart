import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/profile_model.dart';
import '../models/exam_model.dart';
import '../models/term.dart';

/// Tüm shared_preferences erişimini tek yerde toplayan servis.
class StorageService {
  static const String _kCourses = 'saved_courses';
  static const String _kProfile = 'profile';
  static const String _kActiveTerm = 'active_term';
  static const String _kExams = 'saved_exams';
  static const String _kMorningReminder = 'morning_reminder';

  // ---------- DÖNEM ----------

  /// Aktif dönemi döndürür; kayıt yoksa bugünden türetip kaydeder.
  /// Yeni format JSON; eski format düz "2024-Güz" kimliği (geriye dönük).
  static Future<Term> getActiveTerm() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kActiveTerm);
    if (raw == null) {
      final t = Term.current();
      await setActiveTerm(t);
      return t;
    }
    if (raw.trimLeft().startsWith('{')) {
      try {
        return Term.fromJson(json.decode(raw));
      } catch (_) {
        return Term.fromId(raw);
      }
    }
    return Term.fromId(raw); // eski kayıt
  }

  static Future<void> setActiveTerm(Term term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveTerm, json.encode(term.toJson()));
  }

  // ---------- DERSLER ----------

  /// Dersleri yükler. Dönemi boş olan eski kayıtları aktif döneme taşır
  /// ve değişiklik olduysa geri yazar (tek seferlik göç).
  static Future<List<Course>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kCourses);
    if (str == null) return [];

    final List<dynamic> decoded = json.decode(str);
    final courses = decoded.map((e) => Course.fromJson(e)).toList();

    final active = await getActiveTerm();
    bool migrated = false;
    for (final c in courses) {
      if (c.term.isEmpty) {
        c.term = active.id;
        migrated = true;
      }
    }
    if (migrated) await saveCourses(courses);
    return courses;
  }

  static Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final str = json.encode(courses.map((c) => c.toJson()).toList());
    await prefs.setString(_kCourses, str);
  }

  // ---------- PROFİL ----------

  static Future<Profile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kProfile);
    if (str == null) return Profile();
    return Profile.fromJson(json.decode(str));
  }

  static Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, json.encode(profile.toJson()));
  }

  // ---------- SINAVLAR ----------

  static Future<List<Exam>> loadExams() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kExams);
    if (str == null) return [];
    final List<dynamic> decoded = json.decode(str);
    return decoded.map((e) => Exam.fromJson(e)).toList();
  }

  static Future<void> saveExams(List<Exam> exams) async {
    final prefs = await SharedPreferences.getInstance();
    final str = json.encode(exams.map((e) => e.toJson()).toList());
    await prefs.setString(_kExams, str);
  }

  // ---------- BİLDİRİM ANA ANAHTARI ----------

  static Future<bool> getMorningReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMorningReminder) ?? false;
  }

  static Future<void> setMorningReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMorningReminder, value);
  }
}
