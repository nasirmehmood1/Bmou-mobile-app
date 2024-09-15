import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

import 'Constants/language.dart';
import 'Constants/theme.dart';
import 'Data/Local/hive_storage.dart';
import 'Model/ip_data.dart';
import 'View/Splash/splash.dart';
import 'firebase_options.dart';

IPData? ipData;

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (kReleaseMode) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeFirebase();
  await LocalStorage.init();
  await initializeDateFormatting("zh_CH", "").then((_) {
    DateTime now = DateTime.now();
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'en_US').format(now));
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'zh_CH').format(now));
  });

  Pushy.listen();
  Pushy.toggleNotifications(true);
  Pushy.setNotificationListener(backgroundNotificationListener);
  Pushy.toggleInAppBanner(true);

  // ForegroundService().stop();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String languageCode = LocalStorage.getLanguageCode;
    String countryCode = LocalStorage.getCountryCode;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: LocaleString(),
        locale: Locale(languageCode, countryCode),
        fallbackLocale: const Locale('en', 'US'),
        title: "咘呣 Bumou",
        theme: AppTheme.lightTheme(context),
        home: const SplashView(),
      ),
    );
  }
}

@pragma('vm:entry-point')
void backgroundNotificationListener(Map<String, dynamic> data) async {
  log("NOTIFICATION ARRIVED --> ${jsonDecode(data['data'])}");
  if (jsonDecode(data['data'])['sender'] == await LocalStorage.getUserId) {
    log("DUPLICATE NOTIFICATION ARRIVED --> ${jsonDecode(data['data'])['sender']}");
    return;
  }
  ;
  // print(
  //     "NOTIFICATION ARRIVED -- ${}");
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final InitializationSettings notificationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,
      defaultPresentAlert: true,
      defaultPresentBanner: true,
      requestCriticalPermission: true,
    ),
  );

  final bool? isInitialized = await flutterLocalNotificationsPlugin.initialize(
    notificationSettings,
    onDidReceiveBackgroundNotificationResponse:
        _onDidReceiveBackgroundNotificationResponse,
    onDidReceiveNotificationResponse: (message) async {},
  );
  if (isInitialized == null || !isInitialized) {
    print("FAILED TO INITIALIZE NOTIFICATIONS");
    return;
  }

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      "channel_id_4",
      data['title'] ?? '0',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
    ),
    iOS: DarwinNotificationDetails(
      interruptionLevel: InterruptionLevel.timeSensitive,
      presentAlert: true,
      presentSound: true,
      presentBanner: true,
    ),
  );
  flutterLocalNotificationsPlugin.show(
    (await flutterLocalNotificationsPlugin.getActiveNotifications()).length,
    data['title'],
    data['content'],
    platformChannelSpecifics,
    payload: jsonEncode(data),
  );

  Pushy.toggleInAppBanner(false);
}

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse message) async {
  print("Handling a background message: ${message.actionId}");

  await Firebase.initializeApp();

  debugPrint("Background message received" + "-" * 20);
}
