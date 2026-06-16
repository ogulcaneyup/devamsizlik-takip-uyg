import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/course_model.dart';
import 'holiday_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
  }

  static Future<void> requestPermission() async {
    // Android izinleri
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    // iOS izinleri (alert / badge / sound)
    final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // --- ANA AKIŞ: SADECE 00:00 VE 18:00 ALARMLARI ---
  // [activeTermId] verilirse yalnızca o döneme ait dersler hesaba katılır.
  // Susturulmuş (notificationMuted) dersler her zaman dışarıda bırakılır.
  static Future<void> scheduleCourseNotifications(
    List<Course> courses, {
    String? activeTermId,
  }) async {
    await cancelAll();

    final activeCourses = courses.where((c) {
      if (c.notificationMuted) return false;
      if (activeTermId != null && c.term != activeTermId) return false;
      return true;
    }).toList();

    if (activeCourses.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 0;

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      final String dayName = _getDayName(targetDate.weekday);

      // Resmi tatilde ders yokmuş gibi davran
      final dayCourses =
          HolidayService.isHoliday(targetDate)
                ? <Course>[]
                : activeCourses.where((c) => c.days.contains(dayName)).toList()
            ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));

      // GECE 00:00 BİLDİRİMİ (Yarının Programı)
      final midnight = tz.TZDateTime(
        tz.local,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        0,
        0,
      );
      if (midnight.isAfter(now)) {
        if (dayCourses.isEmpty) {
          await _scheduleNotification(
            id: notificationId++,
            title: "✨ Yarın Tatil",
            body:
                "${_getDayName(targetDate.weekday)} hiç dersin yok. Iyi istirahat!",
            scheduledDate: midnight,
          );
        } else {
          final criticalCount = dayCourses
              .where((c) => c.rightsLeft <= 2)
              .length;
          String body = "Yarın ${dayCourses.length} adet dersin var.";
          if (criticalCount > 0) {
            body += " ⚠️ $criticalCount derste hakiniz sınırlanmış!";
          }
          await _scheduleNotification(
            id: notificationId++,
            title: "📚 Yarının Dersleri",
            body: body,
            scheduledDate: midnight,
          );
        }
      }

      // AKŞAM 18:00 BİLDİRİMİ (O gün ders varsa)
      if (dayCourses.isNotEmpty) {
        final evening = tz.TZDateTime(
          tz.local,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          18,
          0,
        );
        if (evening.isAfter(now)) {
          final todayMissingCount = dayCourses
              .where((c) => c.markFor(targetDate) == null)
              .length;
          String body =
              "Bugünkü ${dayCourses.length} dersin durumunu güncelle.";
          if (todayMissingCount == dayCourses.length) {
            body =
                "Hala hiçbir derse gelmedim/geldim işaretlemesi yapmadın! 👋";
          }
          await _scheduleNotification(
            id: notificationId++,
            title: "📝 Günü Tamamla",
            body: body,
            scheduledDate: evening,
          );
        }
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'yeni_trendyol_kanali_v1',
          'Hatırlatıcılar',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static String _getDayName(int weekday) {
    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];
    return days[weekday - 1];
  }
}
