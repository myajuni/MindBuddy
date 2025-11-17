//lib/services/notification_service_mobile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flnp =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _flnp.initialize(settings);

    if (Platform.isAndroid) {
      await _flnp
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    await _flnp
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> cancelAll() async => _flnp.cancelAll();

  Future<void> scheduleOneTime({
    required int id,
    required DateTime when,
    String title = '오늘 대화 하자',
    String body = '마음 정리, 5분 대화 어때요?',
  }) async {
    final tzDateTime = tz.TZDateTime.from(when, tz.local);
    await _flnp.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindbuddy_daily',
          'MindBuddy Daily',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'one-time',
    );
  }

  Future<void> scheduleWeekly({
    required int idBase,
    required TimeOfDay time,
    required List<int> weekdays,
    String title = '오늘 대화 하자',
    String body = '마음 정리, 5분 대화 어때요?',
  }) async {
    for (final w in weekdays) {
      final next = _nextInstanceOfWeekday(time, w);
      await _flnp.zonedSchedule(
        idBase + w,
        title,
        body,
        next,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindbuddy_daily',
            'MindBuddy Daily',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly-$w',
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(TimeOfDay time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
