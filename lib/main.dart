import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:app/Constants/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; 

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart'; 


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
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kReleaseMode) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError 
 = (error, stack) {
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
  await initializeFirebase();
  await LocalStorage.init();
  await initializeDateFormatting("zh_CH", "").then((_) {
    DateTime now = DateTime.now();
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'en_US').format(now));
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'zh_CH').format(now));
  });

  // Initialize Aliyun Push
  await initAliyunPush();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String 
 languageCode = LocalStorage.getLanguageCode;
    String countryCode = LocalStorage.getCountryCode;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: 
 LocaleString(),
        locale: Locale(languageCode, countryCode),
        fallbackLocale: const Locale('en', 'US'),
        title: "咘呣 Bumou",
        theme: AppTheme.lightTheme(context),
        home: const SplashView(),
      ),
    );
  }
}

// Aliyun Push Initialization
Future<void> initAliyunPush() async {
  final AliyunPush aliyunPush = AliyunPush();

  // Create Android channel (if necessary)
  if (Platform.isAndroid) {
    await aliyunPush.createAndroidChannel('8.0up', 'TestChannel', 3, 'Test notification channel');
  }

  // Set message receiver
  aliyunPush.addMessageReceiver(
    onNotification: onNotification,
    onMessage: onMessage,
    onNotificationOpened: onNotificationOpened,
    onNotificationRemoved: onNotificationRemoved,
    onIOSChannelOpened: onIOSChannelOpened,
    onIOSRegisterDeviceTokenSuccess: onIOSRegisterDeviceTokenSuccess,
    onIOSRegisterDeviceTokenFailed: onIOSRegisterDeviceTokenFailed, 

  );

  // Initialize Aliyun Push with your app key and app secret
  String appKey = Apis.aliyueApiKey;
  String appSecret = Apis.aliyueAppSecret;

  await aliyunPush.initPush(appKey: appKey, appSecret: appSecret).then((value) {
    var code = value['code'];
    if (code == kAliyunPushSuccessCode) {
 print('Init Aliyun Push successfully');
 } else {
 String errorMsg = value['errorMsg'];
 print('Init Aliyun Push  not successfully $errorMsg');
  }});
}

// Aliyun Push Callbacks
Future<void> onNotification(Map<dynamic, dynamic> message) async {
  log("Notification Received: $message");
  await showLocalNotification(message);
}

Future<void> onMessage(Map<dynamic, dynamic> message) async {
  log("Message Received: $message");
}

Future<void> onNotificationOpened(Map<dynamic, dynamic> message) async {
  log("Notification Opened: $message");
}

Future<void> onNotificationRemoved(Map<dynamic, dynamic> message) async {
  log("Notification Removed: $message");
}

Future<void> onIOSChannelOpened(Map<dynamic, dynamic> message) async {
  log("iOS Channel Opened: $message");
}

Future<void> onIOSRegisterDeviceTokenSuccess(Map<dynamic, dynamic> message) async {
  log("iOS Device Token Registration Success: $message");
}

Future<void> onIOSRegisterDeviceTokenFailed(Map<dynamic, dynamic> message) async {
  log("iOS Device Token Registration Failed: $message");
}

// Local Notification Handler
Future<void> showLocalNotification(Map<dynamic, dynamic> message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'), 

    iOS: DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: 
 true,
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    onDidReceiveNotificationResponse:
 (message) async {},
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      "channel_id_4",
      message['title'] ?? 'No Title',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    (await flutterLocalNotificationsPlugin.getActiveNotifications()).length,
    message['title'],
    message['content'],
    platformChannelSpecifics,
    payload: jsonEncode(message),
  );
}

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse message) async {
  log("Handling a background message: ${message.actionId}");
}
