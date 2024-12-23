// Developed by @lucns

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitor_queimadas_cariri/firebase/MessagingReceiver.firebase.dart';
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
  BuildContext context = appGlobalKey.currentContext ?? appGlobalKey.currentState!.context;
  switch (response.id) {
    case Constants.NOTIFICATION_ID_INTERNAL_ALERTS:
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
      break;
    default:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
      break;
  }
}

void onFirebaseNotificationClick(RemoteMessage remoteMessage) async {
  RemoteNotification notification = remoteMessage.notification!;
  AndroidNotification? android = notification.android;
  if (android == null) return;
  switch (android.channelId) {
    case Constants.NOTIFICATION_ID_GENERAL:
      break;
    default:
      BuildContext context = appGlobalKey.currentContext ?? appGlobalKey.currentState!.context;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FiresAlertValidationPage()));
      break;
  }
}

void onFirebaseMessageReceived(RemoteMessage remoteMessage) async {
  RemoteNotification notification = remoteMessage.notification!;
  AndroidNotification? android = notification.android;
  if (android == null) return;
  NotificationData notificationData = Constants.notificationsData[android.channelId];
  NotificationProvider notificationProvider = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  await notificationProvider.setChannel(notificationData.channelId!, notificationData.title!, notificationData.description!);
  if (remoteMessage.notification != null) {
    if (await notificationProvider.hasPermission()) {
      notificationProvider.showNotification(ticker: remoteMessage.notification!.title!, title: remoteMessage.notification!.title!, content: remoteMessage.notification!.body!, id: notificationData.notificationId!);
    }
    return;
  }
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
  sl.registerLazySingleton<User>(() => user);

  NotificationProvider notificationProvider = await NotificationProvider.getInstance(onNotificationClick: onNotificationClick);
  notificationProvider.removeAll();

  FirebaseMessagingReceiver messaging = FirebaseMessagingReceiver();
  await messaging.initialize((token) {}, onMessageReceived, onBackgroundMessageReceived, onFirebaseNotificationClick);

  Map<String, dynamic> message = {"app_name": packageInfo.appName, "app_version": packageInfo.version};
  String content = await rootBundle.loadString('assets/files/data.json');
  Map<String, dynamic> data = await json.decode(content);
  FirebaseMessagingSender sender = FirebaseMessagingSender();
  await sender.initialize();
  sender.sendMessage(message, token: data['monitor']);

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

  void initializeNotificationReceiverChannel() async {
    FirebaseMessagingReceiver messaging = FirebaseMessagingReceiver();
    await messaging.subscribeTopic(Constants.FCM_TOPIC_GENERAL_MESSAGES);
    if (widget.user.isAdminstrator()) await messaging.subscribeTopic(Constants.FCM_TOPIC_ALERT_FIRE);
  }

  @override
  void initState() {
    super.initState();
    initializeNotificationReceiverChannel();

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
        home: widget.user.isAuthenticated() ? const MainScreenPage() : const FirstPage());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: double.maxFinite, height: double.maxFinite, color: AppColors.appBackground, child: Center(child: Image.asset('assets/images/monitor_queimadas_cariri.png', width: 184, height: 72)));
  }
}
