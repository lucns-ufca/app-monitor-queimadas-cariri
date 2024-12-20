import 'dart:convert';
import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/utils/Annotator.dart';
import 'package:dio/dio.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
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

  static UserType retrieveType(String role) {
    switch (role) {
      case 'BANNED':
        return UserType.BANNED;
      case 'ADMIN':
        return UserType.ADMINISTRATOR;
      default:
        return UserType.STUDENT;
    }
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

  void setAccessToken(String token, {bool isGoogleAccount = false}) {
    _data.isGoogleAccount = isGoogleAccount;
    _data.accessToken = token;
    _data.expirationDateTime = DateTime.now().add(const Duration(minutes: 15)).toLocal();
  }

  void setRefreshToken(String token) {
    _data.refreshToken = token;
  }

  void setUSerType(int userType) {
    switch (userType) {
      case 0:
        _data.type = UserType.STUDENT;
        break;
      case 1:
        _data.type = UserType.ADMINISTRATOR;
        break;
      default:
        _data.type = UserType.BANNED;
        break;
    }
  }

  bool isExpirate() {
    return DateTime.now().isAfter(_data.expirationDateTime!);
  }

  bool isValidated() {
    return isAuthenticated() && !_data.isGoogleAccount;
  }

  bool isAuthenticated() {
    return _data.accessToken != null;
  }

  bool isAdminstrator() {
    //return _data.type == UserType.ADMINISTRATOR;
    return Constants.WHITE_LIST_EMAILS.any((email) => email == _data.email);
  }

  Future<File?> getProfileImage() async {
    if (_data.photoUrl == null) return null;
    Directory directory = await getApplicationDocumentsDirectory();
    File image = File("${directory.path}/profile_picture.jpg");
    if (await image.exists() && await image.length() > 0) return image;
    Response? response = await _download(_data.photoUrl!, image);
    if (response.statusCode == null) return null;
    if (response.statusCode! > 199 && response.statusCode! < 300) return image;
    return null;
  }

  Future<void> clear() async {
    _data.clear();
  }

  Future<Response> _download(String url, File file) async {
    try {
      Response response = await Api().dio.get(url, options: Options(responseType: ResponseType.bytes, followRedirects: false));
      RandomAccessFile randomAccessFile = await file.open(mode: FileMode.write);
      List<int> imageBytes = response.data as List<int>;
      await randomAccessFile.writeFrom(imageBytes, 0, imageBytes.length);
      await randomAccessFile.close();
      return response;
    } on DioException {
      rethrow;
    }
  }
}

class UserData {
  String? id, name, email, password;
  String? accessToken, refreshToken;
  String? photoUrl;
  DateTime? expirationDateTime;
  bool isGoogleAccount = false;
  UserType type = UserType.STUDENT;

  UserData._();

  Future<void> loadUser() async {
    Annotator a = Annotator("user.json");
    if (!await a.exists()) return;
    String data = await a.getContent();
    Map<String, dynamic> map = jsonDecode(data);
    name = map["name"];
    email = map["email"];
    accessToken = map["access_token"];
    refreshToken = map["refresh_token"];
    id = map["id"];
    photoUrl = map["photo_url"];
    isGoogleAccount = map["is_google_account"];
    expirationDateTime = DateTime.parse(map["expiration_datetime"]);
    int userType = map["user_type"] ?? 0;
    switch (userType) {
      case 0:
        type = UserType.STUDENT;
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
      case UserType.STUDENT:
        userType = 0;
        break;
      case UserType.ADMINISTRATOR:
        userType = 1;
        break;
      default: // UserType.BANNED
    }
    String content = json.encode(
        {"user_type": userType, "expiration_datetime": expirationDateTime!.toIso8601String(), "id": id, "name": name, "email": email, "access_token": accessToken, "refresh_token": refreshToken, "photo_url": photoUrl, 'is_google_account': isGoogleAccount});
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

enum UserType { STUDENT, ADMINISTRATOR, BANNED }
