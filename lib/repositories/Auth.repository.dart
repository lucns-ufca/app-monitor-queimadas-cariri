// @developes by @lucns

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ControllerApi api = ControllerApi(Api(baseUrl: 'https://monitorqueimadas.duckdns.org/'));

  AuthRepository();

  Future<Response?> login(User user) async {
    try {
      Response response = await api.post('auth/login', {"email": user.email, "password": user.password});
      if (response.data == null) return null;

      Map<String, dynamic> map = response.data;
      user.accessToken = map["access_token"];
      if (map.containsKey("user_type")) user.setUSerType(map["user_type"]);
      await user.storeData();

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> createAccount(User user) async {
    try {
      return await api.post('admins', {"username": user.name, "email": user.email, "password": user.password});
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> getUserType(String email) async {
    try {
      return await api.post('user_type', {"email": email});
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<bool> logout() async {
    try {
      Response response = await api.get('logout');
      int code = response.statusCode ?? 0;
      return code > 199 && code < 300;
    } on DioException catch (e) {
      throw (e.message!);
    }
  }
}
