// @developes by @lucns

import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final user = GetIt.I.get<User>();
  final Api api = Api(baseUrl: 'https://monitorqueimadas.duckdns.org/');

  AuthRepository();

  Future<Response?> loginWithGoogleAccount(String email, String name, String accessToken) async {
    String firstName = name.substring(0, name.indexOf(" "));
    String lastName = name.substring(name.indexOf(" ") + 1);
    try {
      Response response = await api.dio.post('auth/google', data: {"email": email, "givenName": firstName, 'familyName': lastName, 'idToken': accessToken});
      if (response.data == null) return null;

      user.setEmail(email);
      user.setType(User.retrieveType(response.data['role']));
      user.setAccessToken(response.data["accessToken"]);
      user.setRefreshToken(response.data["refreshToken"]);
      await user.storeData();

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<Response?> login(String email, String password) async {
    try {
      Response response = await api.dio.post('auth/login', data: {"email": email, "password": password});
      if (response.data == null) return null;

      user.setEmail(email);
      user.setType(User.retrieveType(response.data['role']));
      user.setAccessToken(response.data["access_token"]);
      user.setRefreshToken(response.data["refresh_token"]);
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

  Future<Response?> refreshToken(String accessToken, String refreshToken) async {
    try {
      api.dio.options.headers['Authorization'] = 'Bearer $accessToken';
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
