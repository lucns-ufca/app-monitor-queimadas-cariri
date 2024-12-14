// @developes by @lucns

import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final user = GetIt.I.get<User>();
  final Api api = Api(baseUrl: 'https://monitorqueimadas.duckdns.org/');

  AuthRepository();

  Future<Response?> login(String email, String password) async {
    try {
      Response response = await api.dio.post('auth/login', data: {"email": email, "password": password});
      if (response.data == null) return null;

      user.setEmail(email);
      user.setType(User.retrieveType(response.data['role']));
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
      return await api.dio.post('admins', data: {"username": name, "email": email, "password": password});
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> getUserType(String email) async {
    try {
      return await api.dio.post('user_type', data: {"email": email});
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> refreshToken(String refreshToken) async {
    try {
      Response response = await api.dio.post('auth/refresh', data: {"refreshToken": refreshToken});
      if (response.statusCode == 200) {
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
      Response response = await api.dio.get('logout');
      int code = response.statusCode ?? 0;
      return code > 199 && code < 300;
    } on DioException catch (e) {
      throw (e.message!);
    }
  }
}
