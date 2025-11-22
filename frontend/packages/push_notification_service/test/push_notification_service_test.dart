// ignore_for_file: prefer_const_constructors, unused_local_variable
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:push_notification_service/push_notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockInitializeSettings extends Mock implements InitializationSettings {}

class MockNotificationDetails extends Mock implements NotificationDetails {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

void main() {
  group('Push Notification Service', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setMockMethodCallHandlerFirebase(call) async {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': defaultFirebaseAppName,
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': const <String, String>{},
          }
        ];
      }

      if (call.method == 'Firebase#initializeApp') {
        final arguments = call.arguments as Map;
        return <String, dynamic>{
          'name': arguments['appName'],
          'options': arguments['options'],
          'pluginConstants': const <String, String>{},
        };
      }
    }

    const MethodChannel channel = MethodChannel('test_handler');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, setMockMethodCallHandlerFirebase);
    Firebase.initializeApp();

    setUpAll(() {
      registerFallbackValue(FakeNotificationDetails());
      registerFallbackValue(FakeInitializationSettings());
    });
    late FlutterLocalNotificationsPlugin plugin;
    late PushNotificationService instance;
    IOSFlutterLocalNotificationsPlugin iosFlutterLocalNotificationsPlugin;
    late FirebaseMessaging messaging;

    setUp(() {
      plugin = MockFlutterLocalNotificationsPlugin();
      messaging = MockFirebaseMessaging();
      instance = PushNotificationService(
        messaging: messaging,
        flutterLocalNotificationsPlugin: plugin,
      );
    });

    test('constructor initialized with default plugin', () {
      expect(
        PushNotificationService(),
        isNot(throwsA(isA<Exception>())),
      );
    });

    group('get token', () {
      test('return token', () async {
        when(() => messaging.getToken()).thenAnswer((_) async => 'Token');
        expect(await instance.getFCMToken(), 'Token');
      });

      test('throws exception', () async {
        when(() => messaging.getToken()).thenThrow(Exception());
        expect(() async => instance.getFCMToken(),
            throwsA(isA<GetTokenException>()));
      });
    });

    group('delete token', () {
      test('delete token', () async {
        plugin = MockFlutterLocalNotificationsPlugin();
        messaging = MockFirebaseMessaging();
        instance = PushNotificationService(
          messaging: messaging,
          flutterLocalNotificationsPlugin: plugin,
        );
        when(() => messaging.deleteToken()).thenAnswer((_) async => {});
        expect(instance.deleteToken(), completes);
      });

      test('throws exception', () async {
        plugin = MockFlutterLocalNotificationsPlugin();
        messaging = MockFirebaseMessaging();
        instance = PushNotificationService(
          messaging: messaging,
          flutterLocalNotificationsPlugin: plugin,
        );
        when(() => messaging.deleteToken()).thenThrow(Exception());
        expect(() async => instance.deleteToken(),
            throwsA(isA<DeleteTokenException>()));
      });
    });

    group('refresh token', () {
      test('refresh token', () async {
        plugin = MockFlutterLocalNotificationsPlugin();
        messaging = MockFirebaseMessaging();
        instance = PushNotificationService(
          messaging: messaging,
          flutterLocalNotificationsPlugin: plugin,
        );
        when(() => messaging.onTokenRefresh)
            .thenAnswer((_) => Stream.value('token'));
        await expectLater(
          instance.onTokenRefresh,
          emits('token'),
        );
      });
    });

    group('local notifications initialization', () {
      test('initializes the plugin', () async {
        plugin = MockFlutterLocalNotificationsPlugin();
        when(
          () => plugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((_) => Future.value(true));
        instance = PushNotificationService(
          flutterLocalNotificationsPlugin: plugin,
        );
        expect(instance.init(), completes);
      });
    });

    group('select notification', () {
      setUp(() {
        plugin = MockFlutterLocalNotificationsPlugin();
        instance = PushNotificationService(
          flutterLocalNotificationsPlugin: plugin,
        );
      });
      // test('with payload', () async {
      //   instance.selectNotification(
      //       '{"id":"id","payload":{"id":"1","notification_type":"offerSupport"}}');
      //   expect(
      //       () => instance.selectNotification(
      //           '{"id":"id","payload":{"id":"1","notification_type":"offerSupport"}}'),
      //       isNotNull);
      // });
      test('with payload null', () async {
        instance.selectNotification(null);
        expect(() => instance.selectNotification(null), isNotNull);
      });
    });

    group('permissions', () {
      test('ios permission when null', () {
        when(() => plugin.resolvePlatformSpecificImplementation())
            .thenReturn(null);
        instance.requestIOSPermissions();
        expect(() => instance.requestIOSPermissions(), isNotNull);
      });

      test('ios permission when not null', () {
        iosFlutterLocalNotificationsPlugin =
            MockIOSFlutterLocalNotificationsPlugin();
        when(() => plugin.resolvePlatformSpecificImplementation())
            .thenReturn(iosFlutterLocalNotificationsPlugin);
        when(
          () => iosFlutterLocalNotificationsPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => true);
        instance.requestIOSPermissions();
        expect(() => instance.requestIOSPermissions(), isNotNull);
      });

      test('request permission', () async {
        when(() => messaging.requestPermission(
              alert: true,
              badge: true,
              provisional: false,
              sound: true,
            )).thenAnswer((_) async => NotificationSettings(
              providesAppNotificationSettings: AppleNotificationSetting.enabled,
              criticalAlert: AppleNotificationSetting.disabled,
              alert: AppleNotificationSetting.enabled,
              announcement: AppleNotificationSetting.disabled,
              authorizationStatus: AuthorizationStatus.authorized,
              badge: AppleNotificationSetting.enabled,
              carPlay: AppleNotificationSetting.disabled,
              lockScreen: AppleNotificationSetting.disabled,
              notificationCenter: AppleNotificationSetting.disabled,
              showPreviews: AppleShowPreviewSetting.whenAuthenticated,
              sound: AppleNotificationSetting.enabled,
              timeSensitive: AppleNotificationSetting.enabled,
            ));
        instance.requestPermission();
        expect(
          await instance.requestPermission(),
          isA<NotificationSettings>(),
        );
      });
    });

    group('showPushNotifications', () {
      setUp(() {
        plugin = MockFlutterLocalNotificationsPlugin();
        instance = PushNotificationService(
          flutterLocalNotificationsPlugin: plugin,
        );
      });
      test('completes', () async {
        when(
          () => plugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: jsonEncode(
              PushNotification(
                title: 'title',
                body: 'body',
              ).toJson(),
            ),
          ),
        ).thenAnswer(
          (_) => Future.value(),
        );
        expect(
          instance.showPushNotification(
            PushNotification(
              title: 'title',
              body: 'body',
            ),
          ),
          completes,
        );
      });
    });

    group('onTerminatedApp', () {
      test('payload is not null', () async {
        when(() => messaging.getInitialMessage()).thenAnswer(
          (_) async => RemoteMessage(
            notification: RemoteNotification(title: 'test', body: 'test'),
            data: {'payload': '{}'},
          ),
        );
        expect(
          await instance.onTerminatedApp(),
          isA<PushNotification>(),
        );
      });
      test('payload is  null', () async {
        when(() => messaging.getInitialMessage()).thenAnswer(
          (_) async => RemoteMessage(
            notification: RemoteNotification(title: 'test', body: 'test'),
          ),
        );
        expect(
          await instance.onTerminatedApp(),
          isA<PushNotification>(),
        );
      });
    });

    group('onMessage', () {
      test('when onMessage is listened then received stream of messages', () {
        instance.onMessage.listen(expectAsync1(
          (event) {
            expect(
              event,
              PushNotification(
                title: 'title',
                body: 'body',
                payload: Payload(
                  id: 'id',
                ),
              ),
            );
          },
        ));
        FirebaseMessagingPlatform.onMessage.add(
          RemoteMessage(
            notification: RemoteNotification(
              title: 'title',
              body: 'body',
            ),
            data: {
              'payload': {
                'id': 'id',
                'notification_type': 'offerSupport',
              }
            },
          ),
        );
      });
    });

    group('onMessageOpenedApp', () {
      test(
          'when onMessageOpenedApp is listened then received stream of messages',
          () async {
        instance.onMessageOpenedApp.listen(expectAsync1(
          (event) {
            expect(
              event,
              PushNotification(
                title: 'title',
                body: 'body',
                payload: Payload(
                  id: 'id',
                ),
              ),
            );
          },
        ));
        FirebaseMessagingPlatform.onMessageOpenedApp.add(
          RemoteMessage(
            notification: RemoteNotification(
              title: 'title',
              body: 'body',
            ),
            data: {
              'payload': {
                'id': 'id',
                'notification_type': 'offerSupport',
              }
            },
          ),
        );
      });
    });
  });
}
