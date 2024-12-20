// Developed by @lucns

import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:dio/dio.dart';
import 'package:monitor_queimadas_cariri/models/User.model.dart';
import 'package:monitor_queimadas_cariri/repositories/Auth.repository.dart';

class ControllerApi {
  final user = GetIt.I.get<User>();
  Api api;
  ControllerApi(this.api);

  int getResponseCode() {
    return api.getResponseCode();
  }

  Future<Response> patch(String urlPath) async {
    try {
      if (user.isValidated()) {
        if (user.isExpirate()) await AuthRepository().refreshToken(user.getAccessToken()!, user.getRefreshToken()!);
        api.dio.options.headers['Authorization'] = 'Bearer ${user.getAccessToken()}';
      }
      return await api.dio.patch(urlPath);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> get(String urlPath, {Map<String, dynamic>? parameters}) async {
    try {
      if (user.isValidated()) {
        if (user.isExpirate()) await AuthRepository().refreshToken(user.getAccessToken()!, user.getRefreshToken()!);
        api.dio.options.headers['Authorization'] = 'Bearer ${user.getAccessToken()}';
      }
      return await api.dio.get(urlPath, queryParameters: parameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String urlPath, Object data) async {
    try {
      if (user.isValidated()) {
        if (user.isExpirate()) await AuthRepository().refreshToken(user.getAccessToken()!, user.getRefreshToken()!);
        api.dio.options.headers['Authorization'] = 'Bearer ${user.getAccessToken()}';
      }
      return await api.dio.post(urlPath, data: data);
    } on DioException {
      rethrow;
    }
  }
}

class ApiResponseCodes {
  static const int OK = 200;
  static const int CREATED = 201;
  static const int NO_CONTENT = 204;
  static const int ALREADY_REPORTED = 208;
  static const int GATEWAY_TIMEOUT = 504;
  static const int INSUFFICIENT_STORAGE = 507;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int NOT_FOUND = 404;
  static const int CONFLICT = 409;
}
