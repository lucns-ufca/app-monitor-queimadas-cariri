import 'dart:convert';
import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class User {
  static User? _instance;
  final UserData _data;

  User._(this._data);

  static Future<User> getInstance() async {
    bool initialized = _instance != null;
    _instance ??= User._(UserData._());
    if (!initialized) await _instance!._data.loadUser();
    return _instance!;
  }

  Future<void> storeData() async {
    _data.saveUser();
  }

  String? getName() {
    return _data.name;
  }

  String? getAccessToken() {
    return _data.accessToken;
  }

  String? getRefreshToken() {
    return _data.refreshToken;
  }

  String? getEmail() {
    return _data.email;
  }

  void setName(String name) {
    _data.name = name;
  }

  void setEmail(String email) {
    _data.email = email;
  }

  void setPhotoUrl(String photoUrl) {
    _data.photoUrl = photoUrl;
  }

  void setId(String id) {
    _data.id = id;
  }

  void setType(UserType type) {
    _data.type = type;
  }

  void setAccessToken(String token) {
    _data.accessToken = token;
  }

  void setRefreshToken(String token) {
    _data.refreshToken = token;
  }

  void setUSerType(int userType) {
    switch (userType) {
      case 0:
        _data.type = UserType.NORMAL;
        break;
      case 1:
        _data.type = UserType.ADMINISTRATOR;
        break;
      default:
        _data.type = UserType.BANNED;
        break;
    }
  }

  bool hasAccess() {
    return _data.accessToken != null && _data.accessToken!.isNotEmpty;
  }

  bool isAdminstrator() {
    return _data.type == UserType.ADMINISTRATOR;
  }

  Future<File?> getProfileImage() async {
    if (_data.photoUrl == null) return null;
    Directory directory = await getApplicationDocumentsDirectory();
    File image = File("${directory.path}/profile_picture.jpg");
    if (await image.exists() && await image.length() > 0) return image;
    Response? response = await ControllerApi(Api()).download(_data.photoUrl!, image);
    if (response.statusCode == null) return null;
    if (response.statusCode! > 199 && response.statusCode! < 300) return image;
    return null;
  }

  Future<void> clear() async {
    _data.clear();
  }
}

class UserData {
  String? id, name, email, password;
  String? accessToken, refreshToken;
  String? photoUrl;
  DateTime? dateLogin;
  UserType type = UserType.NORMAL;

  UserData._();

  Future<void> loadUser() async {
    Annotator a = Annotator("user.json");
    if (!await a.exists()) return;
    String data = await a.getContent();
    Map<String, dynamic> map = jsonDecode(data);
    name = map["name"] ?? "";
    email = map["email"] ?? "";
    accessToken = map["access_token"];
    refreshToken = map["refresh_token"];
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

  Future<void> saveUser() async {
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
    String content = json.encode({"user_type": userType, "date_login": dateLogin!.toIso8601String(), "id": id, "name": name, "email": email, "access_token": accessToken, "refresh_token": accessToken, "photo_url": photoUrl});
    await Annotator("user.json").setContent(content);
  }

  Future<void> clear() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/profile_picture.jpg");
    if (await file.exists()) file.delete();
    await Annotator("user.json").delete();
    id = null;
    photoUrl = null;
    accessToken = null;
    refreshToken = null;
    name = null;
    email = null;
    password = null;
  }
}

enum UserType { NORMAL, ADMINISTRATOR, BANNED }
