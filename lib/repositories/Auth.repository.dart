// @developes by @lucns

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ControllerApi api = ControllerApi(Api(baseUrl: 'https://monitorqueimadas.duckdns.org/'));

  AuthRepository();

  Future<Response?> login(String email, String password) async {
    try {
      Response response = await api.post('auth/login', {"email": email, "password": password});
      if (response.data == null) return null;

      User user = await User.getInstance();
      user.setAccessToken(response.data["access_token"]);
      user.setRefreshToken(response.data["refresh_token"]);
      if (response.data.containsKey("user_type")) user.setUSerType(response.data["user_type"]);
      await user.storeData();

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> createAccount(String name, String email, String password) async {
    try {
      return await api.post('admins', {"username": name, "email": email, "password": password});
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

  Future<Response?> refreshToken(String refreshToken) async {
    try {
      Response response = await api.post('auth/refresh', {"refreshToken": refreshToken});
      if (response.statusCode == 200) {
        User user = await User.getInstance();
        user.setAccessToken(response.data["access_token"]);
        user.setRefreshToken(response.data["refresh_token"]);
        await user.storeData();
      }
      return response;
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
