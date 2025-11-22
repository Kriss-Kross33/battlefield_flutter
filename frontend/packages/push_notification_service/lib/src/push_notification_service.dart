import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:push_notification_service/push_notification_service.dart';

/// {@template push_notification_service}
/// Repository which manages the push notifications.
/// {@endtemplate}
class PushNotificationService {
  /// {@macro push_notification_repository}
  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
  })  : messaging = messaging ?? FirebaseMessaging.instance,
        flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ??
            FlutterLocalNotificationsPlugin() {
    onTapForegroundNotification = StreamController<PushNotification>();
  }

  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationDetails? platformChannelSpecifics;
  StreamController<PushNotification>? onTapForegroundNotification;

  /// Requesting permission on iOS
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Flutter Local Notifications settings
  Future<void> init() async {
    ///Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    ///Initialization Settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    ///InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    // Create notification channel for Android 8.0+
    await _createNotificationChannel();

    platformSpecificInitialization();
  }

  /// Create notification channel for Android 8.0+ with custom sound
  Future<void> _createNotificationChannel() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Delete existing channel first to ensure clean setup
      await androidImplementation
          .deleteNotificationChannel('veritas_notifications');

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'veritas_notifications',
        'Veritas Logistics Notifications',
        description: 'Notifications for Veritas Logistics app',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_alert'),
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(channel);
      print('Notification channel created with custom sound: custom_alert');
    }
  }

  /// on Select Notification
  Future<void> selectNotification(
      NotificationResponse? notificationResponse) async {
    final payload = notificationResponse?.payload;
    if (payload != null) {
      final _notification = PushNotification.fromJson(jsonDecode(payload));
      final _payload = _notification.payload;

      if (_payload!.id != null) {
        onTapForegroundNotification?.add(_notification);
      }
    }
  }

  /// platform specific initialization for Displaying Notifications
  void platformSpecificInitialization() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'veritas_notifications', 'Veritas Logistics Notifications',
            channelDescription: 'Notifications for Veritas Logistics app',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            playSound: true);

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'custom_alert.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
      // criticalAlert: false,
    );

    platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  /// Prompts the user for notification permissions.
  Future<NotificationSettings> requestPermission() async {
    await _requestAndroidPermissions();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  Future<void> _requestAndroidPermissions() async {
    if (!Platform.isAndroid) {
      return;
    }

    final status = await Permission.notification.status;

    if (status.isPermanentlyDenied) {
      print(
          'Android notification permission permanently denied. Opening app settings.');
      await openAppSettings();
      return;
    }

    if (status.isDenied || status.isLimited || status.isRestricted) {
      final requestedStatus = await Permission.notification.request();
      print('Android notification permission request result: $requestedStatus');

      if (!requestedStatus.isGranted) {
        return;
      }
    } else {
      print('Android notification permission already granted: $status');
    }

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final permission =
          await androidImplementation.requestNotificationsPermission();
      print('Android notification permission granted: $permission');
    }
  }

  /// Returns a Stream that is called when an incoming FCM payload is received whilst
  /// the Flutter instance is in the foreground.
  Stream<PushNotification> get onMessage {
    return FirebaseMessaging.onMessage.map(
      (message) {
        print('=== FCM FOREGROUND MESSAGE RECEIVED ===');
        print('Message ID: ${message.messageId}');
        print('From: ${message.from}');
        // print('To: ${message.to}');
        print('TTL: ${message.ttl}');
        print('Sent Time: ${message.sentTime}');
        print('Collapse Key: ${message.collapseKey}');
        print('Message Type: ${message.messageType}');

        print('--- Notification Data ---');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print(
            'Android Channel ID: ${message.notification?.android?.channelId}');
        print('Android Sound: ${message.notification?.android?.sound}');
        print('Android Priority: ${message.notification?.android?.priority}');
        // print(
        //     'Android Notification Priority: ${message.notification?.android?.notificationPriority}');
        print(
            'Android Visibility: ${message.notification?.android?.visibility}');
        // print(
        //     'Android Default Sound: ${message.notification?.android?.defaultSound}');
        // print(
        //     'Android Default Vibrate: ${message.notification?.android?.defaultVibrateTimings}');
        // print(
        //     'Android Default Light: ${message.notification?.android?.defaultLightSettings}');

        print('--- Message Data ---');
        message.data.forEach((key, value) {
          print('$key: $value');
        });

        print('--- iOS Specific Data ---');
        print('iOS Sound: ${message.notification?.apple?.sound}');
        print('iOS Badge: ${message.notification?.apple?.badge}');
        // print('iOS Category: ${message.notification?.apple?.categoryIdentifier}');

        print('--- Complete Message Object ---');
        print('Full message: ${message.toString()}');
        print('Message data type: ${message.data.runtimeType}');
        print('Message data keys: ${message.data.keys.toList()}');
        print('Message data values: ${message.data.values.toList()}');

        print('--- Raw JSON Data ---');
        print('Data as JSON: ${jsonEncode(message.data)}');
        print('=====================================');

        // Show the notification with custom sound when app is in foreground
        _showFCMNotification(message);

        return PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          payload: message.data.containsKey('payload')
              ? Payload.fromJson(message.data["payload"])
              : null,
        );
      },
    );
  }

  /// Show FCM notification with custom sound when app is in foreground
  Future<void> _showFCMNotification(RemoteMessage message) async {
    print('=== SHOWING FCM NOTIFICATION WITH CUSTOM SOUND ===');

    // Create notification details with custom sound
    final notificationDetails = Platform.isAndroid
        ? const NotificationDetails(
            android: AndroidNotificationDetails(
              'veritas_notifications',
              'Veritas Logistics Notifications',
              channelDescription: 'Notifications for Veritas Logistics app',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              sound: RawResourceAndroidNotificationSound('custom_alert'),
            ),
          )
        : const NotificationDetails(
            iOS: DarwinNotificationDetails(
              sound: 'custom_alert.caf',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.active,
              // criticalAlert: false,
            ),
          );

    try {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode, // Use message hash as unique ID
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new message',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      print('FCM notification displayed with custom sound');
    } catch (e) {
      print('Error showing FCM notification: $e');
    }
  }

  /// Returns a [Stream] that is called when a user presses a notification message displayed
  /// via FCM.
  Stream<PushNotification> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp.map(
      (message) {
        print('=== FCM MESSAGE OPENED APP ===');
        print('Message ID: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Android Sound: ${message.notification?.android?.sound}');
        print(
            'Android Channel ID: ${message.notification?.android?.channelId}');
        print('Data: ${message.data}');
        print('================================');

        return PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          payload: message.data.containsKey('payload')
              ? Payload.fromJson(message.data["payload"])
              : null,
        );
      },
    );
  }

  /// If the application has been opened from a terminated state via a [RemoteMessage]
  /// (containing a [Notification]), it will be returned, otherwise it will be `null`.
  Future<PushNotification?> onTerminatedApp() async {
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('=== FCM TERMINATED APP MESSAGE ===');
      print('Message ID: ${initialMessage.messageId}');
      print('Title: ${initialMessage.notification?.title}');
      print('Body: ${initialMessage.notification?.body}');
      print('Android Sound: ${initialMessage.notification?.android?.sound}');
      print(
          'Android Channel ID: ${initialMessage.notification?.android?.channelId}');
      print('Data: ${initialMessage.data}');
      print('==================================');

      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        payload: Payload.fromJson(
          jsonDecode(initialMessage.data.containsKey('payload')
              ? initialMessage.data["payload"]
              : '{}'),
        ),
      );
      return notification;
    }
    return null;
  }

  /// Returns the default FCM token for this device.
  Future<String?>? getFCMToken() {
    try {
      if (!Platform.isIOS) {
        return messaging.getToken();
      }
      return messaging.getToken();
    } catch (e) {
      throw GetTokenException();
    }
  }

  /// Deletes the default FCM token for this device.
  Future<void>? deleteToken() {
    try {
      return messaging.deleteToken();
    } catch (e) {
      throw DeleteTokenException();
    }
  }

  /// Fires when a new FCM token is generated.
  Stream<String>? get onTokenRefresh {
    return messaging.onTokenRefresh;
  }

  Future<void> showPushNotification(PushNotification pushNotification) async {
    print('=== SHOWING PUSH NOTIFICATION ===');
    print('Title: ${pushNotification.title}');
    print('Body: ${pushNotification.body}');
    print('Payload: ${pushNotification.payload}');
    print('Platform Channel Specifics: $platformChannelSpecifics');
    print('Notification ID: ${pushNotification.hashCode}');
    print('==================================');

    /// Showing Notification in OS Notification bar
    await flutterLocalNotificationsPlugin.show(
      pushNotification.hashCode,
      pushNotification.title,
      pushNotification.body,
      platformChannelSpecifics,
      payload: jsonEncode(pushNotification.toJson()),
    );

    print('Notification displayed successfully');
  }

  /// Subscribes to given topic
  Future<void> subscribeToTopics({required String topic}) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Test method to show a notification with custom sound
  Future<void> testCustomSoundNotification() async {
    await Future.delayed(const Duration(seconds: 5));
    print('=== TEST CUSTOM SOUND NOTIFICATION ===');
    print('Platform: ${Platform.operatingSystem}');

    // Check notification permissions first
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Check permissions
    if (Platform.isAndroid && androidImplementation != null) {
      final permission =
          await androidImplementation.requestNotificationsPermission();
      print('Android notification permission: $permission');

      final channels = await androidImplementation.getNotificationChannels();
      print(
          'Available notification channels: ${channels?.map((c) => c.id).toList() ?? []}');

      final ourChannel = channels
          ?.where(
            (channel) => channel.id == 'veritas_notifications',
          )
          .firstOrNull;
      print('Our channel exists: ${ourChannel != null}');
      if (ourChannel != null) {
        print('Channel sound: ${ourChannel.sound}');
        print('Channel importance: ${ourChannel.importance}');
      }
    } else if (Platform.isIOS && iosImplementation != null) {
      final permission = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS notification permission: $permission');
    }

    // Create notification details
    final notificationDetails = Platform.isAndroid
        ? const NotificationDetails(
            android: AndroidNotificationDetails(
              'veritas_notifications',
              'Veritas Logistics Notifications',
              channelDescription: 'Notifications for Veritas Logistics app',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              sound: RawResourceAndroidNotificationSound('custom_alert'),
            ),
          )
        : const NotificationDetails(
            iOS: DarwinNotificationDetails(
              sound: 'custom_alert.caf',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.active,
              // criticalAlert: false,
            ),
          );

    print('Notification details: $notificationDetails');
    print('About to show notification...');

    try {
      await flutterLocalNotificationsPlugin.show(
        999, // Use a unique ID for test notifications
        'Custom Sound Test',
        'This notification should play the custom alert sound',
        notificationDetails,
        payload: 'test_custom_sound',
      );
      print('Test notification sent successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }

    print('=== END TEST ===');
  }
}
