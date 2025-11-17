// lib/services/notification_service_web.dart

import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  Future<void> init() async {
    // 웹에서는 알림 미지원 → 아무것도 안 함
    print("Web: Notification init skipped");
  }

  Future<void> requestPermission() async {
    print("Web: Notification permission skipped");
  }

  Future<void> cancelAll() async {
    print("Web: cancelAll skipped");
  }

  // ✅ 모바일에서 존재하는 메서드들을 웹에서도 만들어야 컴파일 에러 없음
  Future<void> scheduleWeekly({
    required int idBase,
    required TimeOfDay time,
    required List<int> weekdays,
    String title = '',
    String body = '',
  }) async {
    print("Web: scheduleWeekly skipped");
  }

  Future<void> scheduleOneTime({
    required int id,
    required DateTime when,
    String title = '',
    String body = '',
  }) async {
    print("Web: scheduleOneTime skipped");
  }
}
