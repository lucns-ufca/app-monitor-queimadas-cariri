import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';

class FirebaseMessagingSender extends FirebaseMessagingSenderBase {
  final Queue<Map<String, dynamic>> queue = Queue<Map<String, dynamic>>();
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

  void setDestineToken(String token) {
    destineToken = token;
  }

  void put(Map<String, dynamic> data) async {
    bool isEmpty = queue.isEmpty;
    queue.add(data);
    if (isEmpty) dequeue();
  }

  void dequeue() async {
    if (accessToken == null || accessToken!.hasExpired) {
      await getAccessToken();
      return;
    }
    while (queue.isNotEmpty) {
      if (await api.hasInternetConnection()) await sendMessaging(queue.removeFirst());
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
  String? destineToken, bearerToken, projectId;

  FirebaseMessagingSenderBase() : api = Api(baseUrl: "https://fcm.googleapis.com/v1/projects/");

  Future<void> sendMessaging(Map<String, dynamic> jsonMessage) async {
    Map<String, dynamic> message = {};
    message["token"] = destineToken;
    message["data"] = jsonMessage;
    Map<String, dynamic> jsonObject = {};
    jsonObject["message"] = message;

    Map<String, dynamic> headers = {"Authorization": "Bearer $bearerToken", "Content-Type": "application/json; UTF-8"};
    api.addHeaders(headers);
    try {
      Response response = await api.dio.post("$projectId/messages:send", data: json.encode(jsonObject));
      log("response code->${response.statusCode}");
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
