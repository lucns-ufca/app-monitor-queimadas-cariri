import 'dart:convert';

import 'package:app_monitor_queimadas/utils/Annotator.dart';

class User {
  String username;
  String email;
  String password;
  String? refreshToken;
  String? accessToken;

  User({this.username = "", this.email = "", this.password = ""});

  Future<void> loadData() async {
    Annotator a = Annotator("user.json");
    if (!a.exists()) return;
    String data = await a.getContent();
    Map<String, dynamic> map = jsonDecode(data);
    username = map["user_name"] ?? "";
    email = map["email"] ?? "";
    refreshToken = map["refresh_token"];
    accessToken = map["access_token"];
  }

  Future<void> storeData() async {
    await Annotator("user.json").setContent(json.encode({"user_name": username, "email": email, "access_token": accessToken!, "refresh_token": refreshToken!}));
  }

  bool hasAccess() {
    return refreshToken != null && accessToken != null;
  }
}
