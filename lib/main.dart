import 'dart:io';
import 'package:belwork/firebase_options.dart';
import 'package:belwork/services/firebase_messaging_service/firebase_messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/main_app_entry.dart';

Future<void> main() async {
  //////////////  flutter binding initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessagingService.instance.init();

  ///////////// devices orientation set
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  //////////// app navigation style set
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.instance.transparent,
      statusBarColor: AppColors.instance.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  ////////////// network
  ////// HttpOverrides.global = MyHttpOverrides(); //// use when i work local with http

  runApp(const MainAppEntry());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (cert, host, port) => kDebugMode;
  }
}
