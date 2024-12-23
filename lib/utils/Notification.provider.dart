import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider {
  static NotificationProvider? _instance;
  final NotificationController _controller;
  NotificationProvider._(this._controller);

  static Future<NotificationProvider> getInstance({void Function(NotificationResponse)? onNotificationClick}) async {
    bool initialized = _instance != null;
    _instance ??= NotificationProvider._(NotificationController._());
    if (!initialized) await _instance!._controller.initialize(onNotificationClick: onNotificationClick!);
    return _instance!;
  }

  Future<void> setChannel(
    String channelId,
    String channelTitle,
    String channelDescription,
  ) async {
    await _controller.createChannel(channelId, channelTitle, channelDescription);
  }

  Future<bool> hasPermission() async {
    return await _controller.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
  }

  Future<bool> requestPermission() async {
    if (await hasPermission()) return true;
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _controller.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.requestNotificationsPermission() ?? false;
  }

  Future<NotificationResponse?> appInitializedByNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await _controller.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null) {
      bool didNotificationLaunchApp = notificationAppLaunchDetails.didNotificationLaunchApp;
      if (didNotificationLaunchApp) return notificationAppLaunchDetails.notificationResponse;
    }
    return null;
  }

  void showNotification({required String ticker, required String title, required String content, required int id}) {
    _controller.show(ticker, title, content, id);
  }

  void removeCurrent(int id) {
    _controller.cancel(id);
  }

  void removeAll() {
    _controller.cancelAll();
  }
}

class NotificationController {
  NotificationController._();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool notificationProviderInitialized = false;
  String? channelId, channelTitle, channelDescription;
  String notificationIcon = const DrawableResourceAndroidIcon('main_notification').data;

  Future<void> initialize({Function(NotificationResponse)? onNotificationClick}) async {
    if (notificationProviderInitialized) return;
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(notificationIcon),
      ),
      onDidReceiveNotificationResponse: onNotificationClick,
      onDidReceiveBackgroundNotificationResponse: onNotificationClick,
    );
    notificationProviderInitialized = true;
  }

  Future<void> createChannel(String channelId, String channelTitle, String channelDescription) async {
    this.channelId = channelId;
    this.channelTitle = channelTitle;
    this.channelDescription = channelDescription;
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelTitle,
      description: channelDescription,
      importance: Importance.low,
    );
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void show(String ticker, String title, String content, int notificationId) {
    flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      content,
      NotificationDetails(
          android: AndroidNotificationDetails(
              ticker: ticker,
              channelId!,
              channelTitle!,
              channelDescription: channelDescription,
              ongoing: false,
              autoCancel: true,
              sound: const RawResourceAndroidNotificationSound('@raw/unsure'),
              //icon: const FlutterBitmapAssetAndroidIcon('assets/icons/main_notification.png').data), // not working
              icon: notificationIcon)),
    );
  }

  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
