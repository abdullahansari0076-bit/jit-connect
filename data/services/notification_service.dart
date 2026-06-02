// lib/data/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../models/app_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Request permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Local notifications setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotifTapped,
    );

    // Create notification channels (Android)
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'class_reminders', 'Class Reminders',
          description: 'Reminders before each class',
          importance: Importance.max,
          playSound: true,
        ));

    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'attendance_alerts', 'Attendance Alerts',
          description: 'Low attendance warnings',
          importance: Importance.high,
        ));

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    // Save FCM token
    final token = await _fcm.getToken();
    if (token != null) await _saveFcmToken(token);
    _fcm.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    final uid = await _getCurrentUid();
    if (uid == null) return;
    await _db.collection(AppConstants.colUsers).doc(uid).update({'fcmToken': token});
  }

  Future<String?> _getCurrentUid() async {
    // Get from auth — implement based on your auth state
    return null;
  }

  // ── Schedule a class reminder ──────────────────────────────────────────────
  Future<void> scheduleClassReminder({
    required int id,
    required String subjectName,
    required String courseId,
    required String room,
    required DateTime classTime,
    required int reminderMinutes,
  }) async {
    final reminderTime = classTime.subtract(Duration(minutes: reminderMinutes));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _localNotif.zonedSchedule(
      id,
      'Class starting in $reminderMinutes minutes',
      '$subjectName · $room',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders', 'Class Reminders',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('class_bell'),
          playSound: true,
          actions: [
            const AndroidNotificationAction('mark_att', 'Mark Attendance', showsUserInterface: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(sound: 'class_bell.aiff'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: courseId,
    );
  }

  // ── Play buzzer tone immediately ───────────────────────────────────────────
  Future<void> playClassBuzzer() async {
    await _audioPlayer.play(AssetSource('sounds/class_bell.mp3'));
  }

  // ── Cancel a scheduled reminder ───────────────────────────────────────────
  Future<void> cancelReminder(int id) async => _localNotif.cancel(id);

  Future<void> cancelAllReminders() async => _localNotif.cancelAll();

  // ── Show local notification from FCM ─────────────────────────────────────
  void _showLocalNotification(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;
    _localNotif.show(
      message.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_alerts', 'Attendance Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _onNotifTapped(NotificationResponse response) {
    // Navigate based on payload — handled by GoRouter
  }

  // ── Save notification to Firestore ────────────────────────────────────────
  Future<void> saveNotification(AppNotification notif) async {
    await _db.collection(AppConstants.colNotifications).add(notif.toFirestore());
  }

  // ── Mark notification as read ─────────────────────────────────────────────
  Future<void> markAsRead(String notifId) async {
    await _db.collection(AppConstants.colNotifications)
        .doc(notifId)
        .update({'isRead': true});
  }

  // ── Stream notifications for user ─────────────────────────────────────────
  Stream<List<AppNotification>> getNotificationsForUser(String uid) {
    return _db.collection(AppConstants.colNotifications)
        .where('recipientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromFirestore(d)).toList());
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
}
