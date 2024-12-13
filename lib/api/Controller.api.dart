// Developed by @lucns

import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:dio/dio.dart';

class ControllerApi {
  Api api;
  ControllerApi(this.api);

  int getResponseCode() {
    return api.getResponseCode();
  }

  Future<Response> download(String url, File file) async {
    try {
      Response response = await api.dio.get(url, options: Options(responseType: ResponseType.bytes, followRedirects: false));
      RandomAccessFile randomAccessFile = await file.open(mode: FileMode.write);
      List<int> imageBytes = response.data as List<int>;
      await randomAccessFile.writeFrom(imageBytes, 0, imageBytes.length);
      await randomAccessFile.close();
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> path(String urlPath) async {
    try {
      //Response response = await api.dio.patch(urlPath);
      //if (response.statusCode != null && response.statusCode == 401) await AuthRepository().refreshToken();
      return await api.dio.patch(urlPath);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> get(String urlPath, {Map<String, dynamic>? parameters}) async {
    try {
      return await api.dio.get(urlPath, queryParameters: parameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String urlPath, Object data) async {
    try {
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
  static const int CONFLIT = 409;
}
