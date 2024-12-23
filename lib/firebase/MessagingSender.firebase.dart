import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';

class FirebaseMessagingSender extends FirebaseMessagingSenderBase {
  final Queue<FirebaseMessagingPayload> queue = Queue<FirebaseMessagingPayload>();
  AccessToken? accessToken;
  bool requestingToken = false;
  Annotator annotator = Annotator("firebase_cloud_messaging_data.json");

  FirebaseMessagingSender() {
    projectId = "monitor-de-queimadas-afd8a";
  }

  Future<void> initialize() async {
    if (await annotator.exists()) {
      String content = await annotator.getContent();
      Map<String, dynamic> map = await json.decode(content);
      if (map.containsKey('access_token')) {
        accessToken = AccessToken.fromJson(map['access_token']);
        bearerToken = accessToken!.data;
      }
    }
  }

  void sendNotification(String title, String body, {String? topic, String? token, String channelId = "default_channel_id"}) {
    bool isEmpty = queue.isEmpty;
    queue.add(FirebaseMessagingPayload(title: title, body: body, topic: topic, token: token, channelId: channelId));
    if (isEmpty) dequeue();
  }

  void sendMessage(Map<String, dynamic> message, {String? topic, String? token}) async {
    bool isEmpty = queue.isEmpty;
    queue.add(FirebaseMessagingPayload(data: message, topic: topic, token: token));
    if (isEmpty) dequeue();
  }

  void dequeue() async {
    if (accessToken == null || accessToken!.hasExpired) {
      await getAccessToken();
      return;
    }
    while (queue.isNotEmpty) {
      if (await api.hasInternetConnection()) send(queue.removeFirst());
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> getAccessToken() async {
    String content = await rootBundle.loadString('assets/files/monitor-de-queimadas-afd8a-3b0bfdee8992.json');
    final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];
    final accountCredentials = ServiceAccountCredentials.fromJson(json.decode(content));

    AuthClient client = await clientViaServiceAccount(accountCredentials, scopes);
    accessToken = client.credentials.accessToken;
    client.close();

    /*
    AutoRefreshingAuthClient autoRefreshingAuthClient = await clientViaServiceAccount(accountCredentials, scopes);
    AccessCredentials credentials = autoRefreshingAuthClient.credentials;
    accessToken = credentials.accessToken;
    bearerToken = accessToken!.data;
    autoRefreshingAuthClient.credentialUpdates.listen((credentials) {
      accessToken = credentials.accessToken;
      bearerToken = accessToken!.data;
    });
    */
    bearerToken = accessToken!.data;

    Map<String, dynamic> map = {};
    if (await annotator.exists()) {
      String content = await annotator.getContent();
      map = await json.decode(content);
    }
    map['access_token'] = accessToken!.toJson();
    await annotator.setContent(json.encode(map));
    if (!accessToken!.hasExpired) dequeue();
  }
}

abstract class FirebaseMessagingSenderBase {
  Api api;
  String? bearerToken, projectId;
  int responseCode = 0;

  FirebaseMessagingSenderBase() : api = Api(baseUrl: "https://fcm.googleapis.com/v1/projects/");

  Future<void> send(FirebaseMessagingPayload messaging) async {
    Map<String, dynamic> message = {};
    if (messaging.token != null) {
      message["token"] = messaging.token;
    } else {
      message["condition"] = "'${messaging.topic}' in topics";
    }
    if (messaging.data != null) {
      message["data"] = messaging.toJson();
    } else {
      message["notification"] = messaging.toJson();
      message["android"] = {
        'notification': {'channel_id': messaging.channelId}
      };
    }
    Map<String, dynamic> payload = {};
    payload["message"] = message;

    Map<String, dynamic> headers = {"Authorization": "Bearer $bearerToken", "Content-Type": "application/json; UTF-8"};
    api.addHeaders(headers);
    try {
      Response response = await api.dio.post("$projectId/messages:send", data: json.encode(payload));
      responseCode = response.statusCode ?? 0;
      //Response response = await api.dio.post("$projectId/messages:send", data: json.encode(jsonObject));
      //log("response code->${response.statusCode}");
    } on DioException catch (e) {
      //e.response!.statusCode
      if (e.response != null) {
        log(e.response!.data.toString());
        //log(e.response!.headers.toString());
        //log(e.response!.requestOptions.toString());
      } else {
        log("Response is null");
        log(e.requestOptions.toString());
        log(e.message.toString());
      }
    }
  }
}

class FirebaseMessagingPayload {
  String? topic, token, title, body, channelId;
  Map<String, dynamic>? data;

  FirebaseMessagingPayload({this.topic, this.token, this.title, this.body, this.data, this.channelId});

  Map<String, dynamic> toJson() {
    if (data == null) {
      return {'title': title, 'body': body};
    }
    return data!;
  }
}
