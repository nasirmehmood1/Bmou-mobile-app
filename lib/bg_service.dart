// this will be used as notification channel id
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unlock_detector/unlock_detector.dart';
import 'package:timezone/data/latest.dart' as tz;

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      // onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  UnlockDetector.stream.listen((event) {
    if (event.isScreenOn) {
      NotificationsService().show();
    }
  });
}

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse message) async {
  print("BG TAATTTT " + " --- " * 20);
}

class NotificationsService {
  show() async {
    tz.initializeTimeZones();

    // WidgetsFlutterBinding.ensureInitialized();

    print("trying to show notification" * 20);

    final FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    bool? initialised = await localNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: (message) async {},
    );

    print("INITALISED --> ${initialised}");

    await localNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'full screen channel id',
          'full screen channel name',
          channelDescription: 'full screen channel description',
          priority: Priority.high,
          importance: Importance.high,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("show notification");
  }
}
