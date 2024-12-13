// Developed by @lucns

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingController.firebase.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingSender.firebase.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/content/admins/FiresAlertValidation.page.dart';
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

final GlobalKey<NavigatorState> appGlobalKey = GlobalKey<NavigatorState>();

void onNotificationClick(NotificationResponse response) {
  if (appGlobalKey.currentContext != null) {
    Navigator.push(appGlobalKey.currentContext!, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
    return;
  }
  if (appGlobalKey.currentState != null) {
    Navigator.push(appGlobalKey.currentState!.context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
    return;
  }
}

void onFirebaseNotificationClick(RemoteMessage remoteMessage) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setInt("page_type", Constants.PAGE_TYPE_VALIDATION);
}

void onFirebaseMessageReceived(RemoteMessage remoteMessage) async {
  NotificationProvider notification = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  await notification.setChannel(Constants.NOTIFICATION_CHANNEL_ID, Constants.NOTIFICATION_CHANNEL_TITLE, Constants.NOTIFICATION_CHANNEL_DESCRIPTION);
  if (remoteMessage.notification != null) {
    if (await notification.hasPermission()) notification.showNotification(ticker: remoteMessage.notification!.title!, title: remoteMessage.notification!.title!, content: remoteMessage.notification!.body!);
    return;
  }

  /*
  Map<String, dynamic> message = remoteMessage.data;
  log("Received->${json.encode(message)}");
  if (message.containsKey("ticker")) {
    if (await notification.hasPermission()) notification.showNotification(ticker: message['ticker'], title: message['title'], content: message['body']);
  }
  */
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(RemoteMessage remoteMessage) async {
  //print("onBackgroundMessageReceived");
}

void onMessageReceived(RemoteMessage? remoteMessage) {
  if (remoteMessage == null) return;
  onFirebaseMessageReceived(remoteMessage);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashScreen());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.appBackground,
    systemNavigationBarColor: AppColors.appBackground,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  User user = await User.getInstance();

  GetIt sl = GetIt.instance;
  sl.allowReassignment = true;
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<PackageInfo>(() => packageInfo);
  sl.registerLazySingleton<AppRepository>(() => AppRepository());

  NotificationProvider notificationProvider = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  await notificationProvider.setChannel(Constants.NOTIFICATION_CHANNEL_ID, Constants.NOTIFICATION_CHANNEL_TITLE, Constants.NOTIFICATION_CHANNEL_DESCRIPTION);
  notificationProvider.removeAll();

  FirebaseMessagingController messaging = FirebaseMessagingController();
  await messaging.initialize((token) {}, onMessageReceived, onBackgroundMessageReceived, onFirebaseNotificationClick);

  //final packageInfo = GetIt.I.get<PackageInfo>();
  Map<String, dynamic> message = {"app_name": packageInfo.appName, "app_version": packageInfo.version};
  String content = await rootBundle.loadString('assets/files/data.json');
  Map<String, dynamic> data = await json.decode(content);
  FirebaseMessagingSender sender = FirebaseMessagingSender();
  await sender.initialize();
  sender.sendMessage(message, token: data['monitor']);

  await Future.delayed(const Duration(milliseconds: 100));
  // bool fromNotification = await notificationProvider.appInitializedByNotification() != null; // not working
  bool fromNotification = (sharedPreferences.getInt('page_type') ?? 0) == Constants.PAGE_TYPE_VALIDATION;
  await sharedPreferences.remove('page_type');
  //await Future.delayed(const Duration(seconds: 1));
  runApp(MainApp(user, fromNotification));
}

class MainApp extends StatefulWidget {
  final User user;
  final bool fromNotification;

  const MainApp(this.user, this.fromNotification, {super.key});

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final appRepository = GetIt.I.get<AppRepository>();

  @override
  void initState() {
    super.initState();
    appRepository.setOnError((responseCode) {
      if (responseCode == 0) {
        Notify.showSnackbarError("Falha ao tentar obter dados!");
        return;
      }
      Notify.showSnackbarError("Falha ao tentar obter dados!\nCodigo: $responseCode");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: Notify.key,
        navigatorKey: appGlobalKey,
        color: AppColors.appBackground,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(primary: Colors.white, seedColor: AppColors.accent),
          useMaterial3: true,
        ),
        home: widget.user.hasAccess() ? MainScreenPage(fromNotification: widget.fromNotification) : const FirstPage());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: double.maxFinite, height: double.maxFinite, color: AppColors.appBackground, child: Center(child: Image.asset('assets/images/monitor_queimadas_cariri.png', width: 184, height: 72)));
  }
}
