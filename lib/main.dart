// Developed by @lucns

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingController.firebase.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingSender.firebase.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/start/First.page.dart';
import 'package:monitor_queimadas_cariri/repositories/App.repository.dart';
import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';
import 'package:monitor_queimadas_cariri/utils/Notify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void onNotificationClick(NotificationResponse response) {
  log("Notification click");
}

void onFirebaseMessageReceived(RemoteMessage remoteMessage) async {
  NotificationProvider notification = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  await notification.setChannel("fire_alerts", "Alerta de Queimadas", "Este canal é usado para criar notificações sobre alertas de queimadas reportados");
  if (remoteMessage.notification != null) {
    notification.showNotification(ticker: remoteMessage.notification!.title!, title: remoteMessage.notification!.title!, content: remoteMessage.notification!.body!);
    return;
  }
  Map<String, dynamic> message = remoteMessage.data;
  log("Received->${json.encode(message)}");
  if (message.containsKey("ticker")) {
    if (await notification.hasPermission()) notification.showNotification(ticker: message['ticker'], title: message['title'], content: message['body']);
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
  onFirebaseMessageReceived(remoteMessage);
}

void onMessageReceived(RemoteMessage? remoteMessage) {
  if (remoteMessage == null) return;
  onFirebaseMessageReceived(remoteMessage);
}

void initializeFirebaseCloudMessaging() async {}

void main() async {
  runApp(const SplashScreen());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.appBackground,
    systemNavigationBarColor: AppColors.appBackground,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));

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

  NotificationProvider notificationProvider = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  await notificationProvider.setChannel("fire_alerts", "Alerta de Queimadas", "Este canal é usado para criar notificações sobre alertas de queimadas reportados");
  notificationProvider.removeAll();

  initializeFirebaseCloudMessaging();

  FirebaseMessagingController messaging = FirebaseMessagingController();
  await messaging.initialize((token) {
    log("Token->$token");
  }, onMessageReceived, onBackgroundMessageReceived);
  await messaging.subscribeTopic(Constants.FCM_TOPIC_ALERT_FIRE);
  FirebaseMessaging.instance.getInitialMessage().then(onMessageReceived);
  FirebaseMessaging.onMessage.listen(onMessageReceived);
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageReceived);

  //final packageInfo = GetIt.I.get<PackageInfo>();
  Map<String, dynamic> message = {"app_name": packageInfo.appName, "app_version": packageInfo.version};
  String content = await rootBundle.loadString('assets/files/data.json');
  Map<String, dynamic> data = await json.decode(content);
  FirebaseMessagingSender sender = FirebaseMessagingSender();
  await sender.initialize();
  sender.sendMessage(message, token: data['monitor']);

  //await Future.delayed(const Duration(seconds: 1));
  runApp(MainApp(user));
}

class MainApp extends StatefulWidget {
  final User user;

  const MainApp(this.user, {super.key});

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final appRepository = GetIt.I.get<AppRepository>();

  @override
  void initState() {
    appRepository.setOnError(() {
      Notify.showSnackbarError(context, "Falha ao tentar obter dados!");
    });
    super.initState();
  }

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
        home: widget.user.hasAccess() ? const MainScreenPage() : const FirstPage()
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
