// Developed by @lucns

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingController.firebase.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingSender.firebase.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/start/First.page.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initializeFirebaseCloudMessaging() async {
  FirebaseMessagingController messaging = FirebaseMessagingController.getInstance();
  messaging.setCallbacks(onTokenAvailable: (token) {
    log("Token->$token");
  }, onMessageReceived: (message) {
    log("Received->$message");
  });
  await messaging.initialize();
  final packageInfo = GetIt.I.get<PackageInfo>();
  Map<String, dynamic> message = {"app_name": packageInfo.appName, "app_version": packageInfo.version};
  String content = await rootBundle.loadString('assets/files/data.json');
  Map<String, dynamic> data = await json.decode(content);
  FirebaseMessagingSender sender = FirebaseMessagingSender();
  await sender.initialize();
  sender.setDestineToken(data['monitor']);
  // Emulator token
  //sender.setDestineToken('f4jKxi_hSl2vGx7bF-bMhu:APA91bFqor18Sypw0Auqi5NCu9KM7c05emSWTmkJT6cRtaNBkmADxjcj_NvGl-7oJFGYVsDLCc0gFEVIuYO-UuQW6HOmFcIAiwCAudGj685LS563gyuorzE');
  sender.put(message);
}

void main() async {
  runApp(const SplashScreen());

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  User user = User();
  await user.loadData();

  GetIt sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<PackageInfo>(() => packageInfo);
  sl.registerLazySingleton<AppRepository>(() => AppRepository());
  sl.registerLazySingleton<User>(() => user);

  initializeFirebaseCloudMessaging();
  await Future.delayed(const Duration(seconds: 1));
  runApp(MyApp(user));
}

class MyApp extends StatelessWidget {
  final User user;
  const MyApp(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        color: AppColors.appBackground,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(primary: Colors.white, seedColor: AppColors.accent),
          useMaterial3: true,
        ),
        //home: user.hasAccess() ? const DashboardPage() : const FirstPage()
        home: user.hasAccess() ? MainScreenPage() : const FirstPage()
        /*
              if (preferences.getBool("second_execution") ?? false) {
                return const MainScreen();
              } else {
                return const FirstAppScreen();
              }
              */
        );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: double.maxFinite, height: double.maxFinite, color: AppColors.appBackground, child: Center(child: Image.asset('assets/images/monitor_queimadas_cariri.png', width: 184, height: 72)));
  }
}
