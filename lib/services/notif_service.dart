import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    tz.initializeTimeZones();

    final String timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezone));

    print("Timezone: $timezone");
    print("Location : ${tz.local.name}");
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("NOW       : $now");
    print("SCHEDULED : $scheduledDate");

    await notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminder',
          'Meal Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> setupMealReminders() async {
    await scheduleDailyNotification(
      id: 1,
      title: 'Sarapan',
      body: 'Ayo cari resep sarapan yang lezat!',
      hour: 7,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 2,
      title: 'Makan Siang',
      body: 'Cari inspirasi makan siang yuk!',
      hour: 12,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 3,
      title: 'Makan Malam',
      body: 'Saatnya menyiapkan makan malam!',
      hour: 18,
      minute: 0,
    );
  }

/*
  static Future<void> showTestNotification() async {
    await notifications.show(
      999,
      'Test Notification',
      'Jika ini muncul, plugin bekerja.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> scheduleTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 10));

    print("Scheduled at: $scheduledDate");

    await notifications.zonedSchedule(
      999,
      "Test",
      "10 detik lagi",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "test_channel",
          "Test Channel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  */
}
