// Developed by @lucns

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';

class FirebaseMessagingController {
  String? token;

  FirebaseMessagingController();

  Future<void> initialize(void Function(String) onTokenAvailable, void Function(RemoteMessage?) onMessageReceived, Future<void> Function(RemoteMessage) onBackgroundMessageReceived) async {
    //https://console.firebase.google.com/project/monitor-queimadas-cariri/settings/cloudmessaging/android:lucns.monitor_queimadas_cariri
    // apiKey = Chave de API da Web
    // messagingSenderId = Número do projeto/ID do remetente
    // projectId = Código do projeto
    // vapidKey = Certificados push da Web
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey: 'AIzaSyApoI4pdAMP7pVaeHygN_UdR015arj7O2w', appId: '1:488506511908:android:cbe059493415167799feb1', messagingSenderId: '488506511908', projectId: 'monitor-de-queimadas-afd8a'));

    FirebaseMessaging.instance.getToken(vapidKey: 'BINB5jD3KJzkG8dHL4MJqlI9KLRTaNeHiFwvOjiuI4CFEP_ADqjYAcgiKS40UeIf1b5kCIEQFbKvJqTnB0DWb6Q').then((token) async {
      if (token != null && await retrieveToken(token)) onTokenAvailable(token);
      FirebaseMessaging.instance.onTokenRefresh.listen((refreshToken) async {
        if (await retrieveToken(refreshToken)) onTokenAvailable(refreshToken);
      });
    });
    FirebaseMessaging.instance.getInitialMessage().then(onMessageReceived);
    FirebaseMessaging.onMessage.listen(onMessageReceived);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageReceived);
  }

  Future<bool> retrieveToken(String token) async {
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
    return token != lastToken;
  }

  String? getToken() {
    return token;
  }

  Future<void> subscribeTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unSubscribeTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
