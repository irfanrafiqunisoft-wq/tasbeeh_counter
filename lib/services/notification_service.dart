import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Har Tasbeeh ke liye apna daily reminder notification schedule karta hai.
/// Notification ID = tasbeeh ke 'id' string ka hashCode (unique rehta hai).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _timezoneReady = false;

  static Future<void> init() async {
    if (_initialized) return;

    if (!_timezoneReady) {
      tz_data.initializeTimeZones();
      _timezoneReady = true;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static int _notificationIdForTasbeeh(String tasbeehId) {
    return tasbeehId.hashCode & 0x7FFFFFFF; // positive 32-bit id
  }

  static Future<void> scheduleDailyReminder({
    required String tasbeehId,
    required String tasbeehName,
    required int hour,
    required int minute,
  }) async {
    await init();
    final id = _notificationIdForTasbeeh(tasbeehId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'tasbeeh_daily_reminder',
      'Daily Tasbeeh Reminders',
      channelDescription: 'Roz ek waqt par tasbeeh yaad dehani',
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        'Tasbeeh Reminder',
        'Waqt ho gaya hai - $tasbeehName poora karne ka.',
        scheduledDate,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time, // daily repeat
      );
    } catch (e) {
      // Agar exact/inexact alarm permission masla ho, app crash nahi honi chahiye.
      // Reminder simply schedule nahi hoga, lekin baqi app kaam karta rahega.
    }
  }

  static Future<void> cancelReminder(String tasbeehId) async {
    await init();
    final id = _notificationIdForTasbeeh(tasbeehId);
    await _plugin.cancel(id);
  }

  static Future<void> requestPermissions() async {
    await init();
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }
}
