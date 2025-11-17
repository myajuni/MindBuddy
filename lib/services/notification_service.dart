//lib/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // 싱글톤
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    debugPrint('[WEB] NotificationService.init() — skipped');
  }

  Future<bool> areNotificationsEnabled() async {
    return false; // 웹은 알림 미지원
  }

  Future<void> cancelAll() async {
    debugPrint('[WEB] cancelAll() ignored');
  }

  Future<void> showNow({String title = '', String body = ''}) async {
    debugPrint(
        '[WEB] showNow() ignored (web does not support local notifications)');
  }

  Future<void> showInSeconds(int seconds,
      {String title = '', String body = ''}) async {
    debugPrint('[WEB] showInSeconds() ignored');
  }

  Future<void> scheduleOneTime({
    required int id,
    required DateTime when,
    String title = '',
    String body = '',
  }) async {
    debugPrint('[WEB] scheduleOneTime() ignored');
  }

  Future<void> scheduleWeekly({
    required int idBase,
    required TimeOfDay time,
    required List<int> weekdays,
    String title = '',
    String body = '',
  }) async {
    debugPrint('[WEB] scheduleWeekly() ignored');
  }
}
