import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("d7785c40-cb60-4c08-bf09-d64a59dc0066");

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
