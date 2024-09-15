import 'dart:convert';

import 'package:app_monitor_queimadas/utils/Annotator.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String accessToken;
  String photoUrl;
  DateTime? dateLogin;
  UserType userType = UserType.NORMAL;

  User({this.id = "", this.photoUrl = "", this.accessToken = "", this.name = "", this.email = "", this.password = ""});

  Future<void> loadData() async {
    Annotator a = Annotator("user.json");
    if (!a.exists()) return;
    String data = await a.getContent();
    Map<String, dynamic> map = jsonDecode(data);
    name = map["name"] ?? "";
    email = map["email"] ?? "";
    accessToken = map["access_token"];
    accessToken = map["id"];
    dateLogin = DateTime.parse(map["date_login"]);
    int type = map["user_type"] ?? 0;
    switch (type) {
      case 0:
        userType = UserType.NORMAL;
        break;
      case 1:
        userType = UserType.ADMINISTRATOR;
        break;
      default:
        userType = UserType.BANNED;
        break;
    }
  }

  Future<void> storeData() async {
    int type = 0;
    switch (userType) {
      case UserType.NORMAL:
        type = 1;
        break;
      case UserType.ADMINISTRATOR:
        type = 2;
        break;
      default: // UserType.BANNED
    }
    dateLogin = DateTime.now().toLocal();
    String content = json.encode({"user_type": type, "date_login": dateLogin!.toIso8601String(), "id": id, "name": name, "email": email, "access_token": accessToken, "photo_url": photoUrl});
    await Annotator("user.json").setContent(content);
  }

  void setUSerType(int type) {
    switch (type) {
      case 0:
        userType = UserType.NORMAL;
        break;
      case 1:
        userType = UserType.ADMINISTRATOR;
        break;
      default:
        userType = UserType.BANNED;
        break;
    }
  }

  bool hasAccess() {
    return accessToken.isNotEmpty;
  }
}

enum UserType { NORMAL, ADMINISTRATOR, BANNED }
