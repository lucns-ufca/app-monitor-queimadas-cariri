// Developed by @lucns

import 'dart:io';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ControllerApi {
  bool recursible = false;
  Api api;
  ControllerApi(this.api);

  static String getError(int code) {
    // Generic response messages
    switch (code) {
      case ApiResponseCodes.BAD_REQUEST:
        return "O servidor não entendeu sua solicitação. Talvez seja necessário atualizar o app.";
      case ApiResponseCodes.GATEWAY_TIMEOUT:
        return "O servidor não respondeu. Prazo de espera estourado.";
      case ApiResponseCodes.UNAUTHORIZED:
        return "Você precisa fazer login novamente.";
      default:
        return "Um erro desconhecido ocorreu.";
    }
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

  Future<Response> get(String urlPath, {Map<String, dynamic>? parameters}) async {
    try {
      if (recursible) {
        return _getRecursible(urlPath, parameters: parameters);
      } else {
        return _get(urlPath, parameters: parameters);
      }
    } on DioException {
      rethrow;
    }
  }

  Future<Response> _getRecursible(String urlPath, {Map<String, dynamic>? parameters}) async {
    if (recursible) {
      for (int i = 0; i < 10; i++) {
        try {
          Response response = await _get(urlPath, parameters: parameters);
          if (i == 9 || (response.statusCode! > 199 && response.statusCode! < 300)) return response;
        } on DioException catch (e) {
          print(e);
          if (!await hasInternetConnection() || i == 9) rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      return Response(requestOptions: RequestOptions());
    } else {
      return _get(urlPath, parameters: parameters);
    }
  }

  Future<Response> _get(String urlPath, {Map<String, dynamic>? parameters}) async {
    try {
      return await api.dio.get(urlPath, queryParameters: parameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String urlPath, Object data) async {
    try {
      if (recursible) {
        return _postRecursible(urlPath, data);
      } else {
        return _post(urlPath, data);
      }
    } on DioException {
      rethrow;
    }
  }

  Future<Response> _postRecursible(String urlPath, Object data) async {
    if (recursible) {
      for (int i = 0; i < 10; i++) {
        try {
          Response response = await _post(urlPath, data);
          if (i == 9 || (response.statusCode! > 199 && response.statusCode! < 300)) return response;
        } on DioException catch (e) {
          print(e);
          if (!await hasInternetConnection() || i == 9) rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      return Response(requestOptions: RequestOptions());
    } else {
      return _post(urlPath, data);
    }
  }

  Future<Response> _post(String urlPath, Object data) async {
    try {
      return await api.dio.post(urlPath, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((item) => item == ConnectivityResult.mobile) || connectivityResult.any((item) => item == ConnectivityResult.wifi);
  }
}

class ApiResponse {
  String? message;
  dynamic data;
  int? code;

  ApiResponse({this.message, this.data, this.code});

  bool isOk() => code != null && (code! > 199 && code! < 300);
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