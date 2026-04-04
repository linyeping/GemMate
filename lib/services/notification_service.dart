import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../core/constants.dart';
import '../stores/locale_store.dart';
import '../models/flashcard.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    // Setting to Shanghai since the user is likely in China
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (e) {
      print('Timezone initialization failed: $e');
    }
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );

    // Create notification channel explicitly for Android 8+
    const channel = AndroidNotificationChannel(
      'study_reminders',
      'Study Reminders',
      description: 'Reminders to review flashcards and study',
      importance: Importance.max,
    );
    
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission on Android 13+
    await requestPermission();
  }

  Future<void> scheduleReviewReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool ignoreQuietHours = false,
  }) async {
    DateTime correctedTime = scheduledTime;
    
    // Respect quiet hours 10pm-8am unless ignored
    if (!ignoreQuietHours) {
      if (correctedTime.hour >= 22 || correctedTime.hour < 8) {
        correctedTime = DateTime(
          correctedTime.year,
          correctedTime.month,
          correctedTime.hour >= 22 ? correctedTime.day + 1 : correctedTime.day,
          8,
          0,
        );
      }
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(correctedTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminders',
          'Study Reminders',
          channelDescription: 'Reminders to review flashcards and study',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleFlashcardReminders(List<Flashcard> cards) async {
    final dueCards = cards.where((c) => c.nextReview.isBefore(DateTime.now())).toList();
    await scheduleReminders(dueCards.length, cards.length);
  }

  Future<void> scheduleReminders(int dueCount, int totalCount) async {
    await _plugin.cancelAll();
    
    final lang = LocaleStore().languageCode;
    
    if (dueCount > 0) {
      final title = lang == 'zh' ? '🎯 该复习了！' : '🎯 Review Time!';
      final body = lang == 'zh' 
          ? '你有 $dueCount 张闪卡待复习 — 保持你的学习进度！' 
          : 'You have $dueCount flashcards ready for review — keep your streak going!';
          
      await scheduleReviewReminder(
        id: 1,
        title: title,
        body: body,
        scheduledTime: DateTime.now().add(const Duration(hours: AppConstants.reviewReminderHours)),
      );
    }

    final inactivityTitle = lang == 'zh' ? '📚 别忘了学习！' : '📚 Don\'t forget!';
    final inactivityBody = lang == 'zh'
        ? '知识正在慢慢遗忘... 来一次 2 分钟的快速复习吧？'
        : 'Your knowledge is fading... How about a quick 2-minute review?';
        
    await scheduleReviewReminder(
      id: 2,
      title: inactivityTitle,
      body: inactivityBody,
      scheduledTime: DateTime.now().add(const Duration(hours: AppConstants.inactivityReminderHours)),
    );

    await _scheduleDaily(
      id: 3,
      title: lang == 'zh' ? '☀️ 早上好！' : '☀️ Good morning!',
      body: lang == 'zh' ? '今天也要和 Gemma 一起进步吗？' : 'Ready to study with Gemma today?',
      hour: AppConstants.dailyReminderHour,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminders',
          'Study Reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelInactivityReminder() async {
    await _plugin.cancel(2);
  }

  Future<void> showInstant({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'study_reminders',
      'Study Reminders',
      channelDescription: 'Reminders to review flashcards and study',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      99,
      title,
      body,
      details,
    );
  }
}
