import 'dart:convert';
import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String accessToken;
  String photoUrl;
  DateTime? dateLogin;
  UserType type = UserType.NORMAL;

  User({this.id = "", this.photoUrl = "", this.accessToken = "", this.name = "", this.email = "", this.password = ""});

  Future<void> loadData() async {
    Annotator a = Annotator("user.json");
    if (!await a.exists()) return;
    String data = await a.getContent();
    Map<String, dynamic> map = jsonDecode(data);
    name = map["name"] ?? "";
    email = map["email"] ?? "";
    accessToken = map["access_token"];
    id = map["id"];
    photoUrl = map["photo_url"];
    dateLogin = DateTime.parse(map["date_login"]);
    int userType = map["user_type"] ?? 0;
    switch (userType) {
      case 0:
        type = UserType.NORMAL;
        break;
      case 1:
        type = UserType.ADMINISTRATOR;
        break;
      default:
        type = UserType.BANNED;
        break;
    }
  }

  Future<void> storeData() async {
    int userType = 0;
    switch (type) {
      case UserType.NORMAL:
        userType = 0;
        break;
      case UserType.ADMINISTRATOR:
        userType = 1;
        break;
      default: // UserType.BANNED
    }
    dateLogin = DateTime.now().toLocal();
    GetIt.instance.registerLazySingleton<User>(() => this);
    String content = json.encode({"user_type": userType, "date_login": dateLogin!.toIso8601String(), "id": id, "name": name, "email": email, "access_token": accessToken, "photo_url": photoUrl});
    await Annotator("user.json").setContent(content);
  }

  void setUSerType(int userType) {
    switch (userType) {
      case 0:
        type = UserType.NORMAL;
        break;
      case 1:
        type = UserType.ADMINISTRATOR;
        break;
      default:
        type = UserType.BANNED;
        break;
    }
  }

  bool hasAccess() {
    return email.isNotEmpty;
    //return accessToken.isNotEmpty;
  }

  bool isAdminstrator() {
    return type == UserType.ADMINISTRATOR;
  }

  Future<File?> getProfileImage() async {
    if (photoUrl.isEmpty) return null;
    Directory directory = await getApplicationDocumentsDirectory();
    File image = File("${directory.path}/profile_picture.jpg");
    if (await image.exists() && await image.length() > 0) return image;
    Response? response = await ControllerApi(Api()).download(photoUrl, image);
    if (response.statusCode == null) return null;
    if (response.statusCode! > 199 && response.statusCode! < 300) return image;
    return null;
  }

  Future<void> clear() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/profile_picture.jpg");
    if (await file.exists()) file.delete();
    await Annotator("user.json").delete();
    id = "";
    photoUrl = "";
    accessToken = "";
    name = "";
    email = "";
    password = "";
    GetIt.instance.registerLazySingleton<User>(() => this);
  }
}

enum UserType { NORMAL, ADMINISTRATOR, BANNED }
