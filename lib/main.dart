import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pickme_mobile/config/firebase/firebaseConfig.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';

import 'config/localNotification/firebaseNotificationService.dart';
import 'config/localNotification/notificationService.dart';
import 'config/localNotification/permissionsService.dart';
import 'firebase_options.dart';
import 'pages/onboarding/splashScreen.dart';
import 'spec/properties.dart';
import 'spec/theme.dart';

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  BindingBase.debugZoneErrorsAreFatal = true;

  // runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, stackTrace) {
      FirebaseService().reportErrors(
        e.toString(),
        stackTrace.toString(),
        requestBody: {
          "function": "main - Initialize Firebase",
        },
      );
    }

    await FirebaseConfig.instance.initialize();

    // Initialize notifications
    await initializeNotifications();
    await setupNotificationChannel();
    await requestIOSPermissions();

    // Initialize Hive
    try {
      await Hive.initFlutter();
      await Hive.openLazyBox(Properties.hiveBox);
    } catch (e, stackTrace) {
      FirebaseService().reportErrors(
        e.toString(),
        stackTrace.toString(),
        requestBody: {
          "function": "main - Initialize Hive",
        },
      );
      if (kDebugMode) {
        print('Error initializing Hive: $e');
      }
    }

    // Set Flutter framework error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
    };

    runApp(const MyApp());
  // }, (error, stackTrace) {
  //   // Report error to Firebase Crashlytics
  //   FirebaseCrashlytics.instance.recordError(error, stackTrace);

  //   // Report error to a logging service
  //   FirebaseService().reportErrors(
  //     error.toString(),
  //     stackTrace.toString(),
  //     requestBody: {
  //       "function": "main - runZonedGuarded",
  //     },
  //   );

  //   if (kDebugMode) {
  //     print('Caught Dart error: $error');
  //     print('Stack trace: $stackTrace');
  //   } else {
  //     // Show a user-friendly message or restart the app
  //   }
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupFirebaseMessaging();
    });
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      navigatorKey: mainNavigatorKey,
      theme: Themes.theme(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
