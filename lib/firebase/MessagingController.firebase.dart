// Developed by @lucns

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';

class FirebaseMessagingController {
  static FirebaseMessagingController? _instance;
  final Messaging _controller;
  Function(String)? onTokenAvailable, onMessageReceived;
  FirebaseMessagingController._(this._controller);
  String? token;

  static FirebaseMessagingController getInstance() {
    //bool initialized = _instance != null;
    _instance ??= FirebaseMessagingController._(Messaging._());
    //if (!initialized) _initialize();
    return _instance!;
  }

  Future<void> initialize() async {
    await _instance!._controller.initializeFirebase((token) async {
      this.token = token;

      Annotator annotator = Annotator("firebase_cloud_messaging_data.json");
      Map<String, dynamic> map = {};
      if (await annotator.exists()) {
        String content = await annotator.getContent();
        map = await json.decode(content);
      }
      String lastToken = "";
      if (map.containsKey('client_token')) lastToken = map['client_token'];
      map['client_token'] = token;
      await annotator.setContent(json.encode(map));

      if (token != lastToken) onTokenAvailable!(token);
    }, onMessageReceived!);
  }

  void setCallbacks({Function(String)? onTokenAvailable, Function(String)? onMessageReceived}) {
    this.onTokenAvailable = onTokenAvailable;
    this.onMessageReceived = onMessageReceived;
  }

  String? getToken() {
    return token;
  }
}

class Messaging {
  Messaging._();

  Future<void> initializeFirebase(Function(String) onTokenAvailable, Function(String) onMessageReceived) async {
    //https://console.firebase.google.com/project/monitor-queimadas-cariri/settings/cloudmessaging/android:lucns.monitor_queimadas_cariri
    // apiKey = Chave de API da Web
    // messagingSenderId = Número do projeto/ID do remetente
    // projectId = Código do projeto
    // vapidKey = Certificados push da Web
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey: 'AIzaSyApoI4pdAMP7pVaeHygN_UdR015arj7O2w', appId: '1:488506511908:android:cbe059493415167799feb1', messagingSenderId: '488506511908', projectId: 'monitor-de-queimadas-afd8a'));

    FirebaseMessaging.instance.getToken(vapidKey: 'BINB5jD3KJzkG8dHL4MJqlI9KLRTaNeHiFwvOjiuI4CFEP_ADqjYAcgiKS40UeIf1b5kCIEQFbKvJqTnB0DWb6Q').then((token) {
      if (token != null) onTokenAvailable(token); // d5Vb-0lXShmVjEpw1GORFD:APA91bGB6UXtFMGg7wLl6GyxX2DvFdHQOexrnKqNkoqEDfHo_H8tFPl65OgRkAzSab9atguyocjxK_VvrLgptSJaMfnmdnBXOXtN-2DgHybF9M5YDUiPoz8
      FirebaseMessaging.instance.onTokenRefresh.listen((refreshToken) {
        onTokenAvailable(refreshToken);
      });
    });
    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage) {
      if (remoteMessage == null) return;
      onMessageReceived(remoteMessage.data.toString());
    });

    FirebaseMessaging.onMessage.listen((remoteMessage) {
      onMessageReceived(remoteMessage.data.toString());
    });
    //FirebaseMessaging.onBackgroundMessage(onMessageReceived);
  }
}
