import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Initialiser les timezones
    tz.initializeTimeZones();

    // Configurer Firebase Messaging
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurer les notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Gérer les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Gérer les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  // Gestionnaire de messages en arrière-plan
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Afficher une notification locale
    final FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
        
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await localNotificationsPlugin.initialize(initializationSettings);
    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  // Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  // Planifier une notification locale
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _localNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Envoyer un message via FCM
  Future<void> sendNotificationToUser({
    required String token,
    required String title,
    required String body,
  }) async {
    // Dans une vraie application, cela serait fait via un backend
    // Ici, nous simulons l'envoi d'une notification locale
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}