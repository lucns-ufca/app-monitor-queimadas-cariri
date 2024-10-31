import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Api {
  final Dio dio;

  Api(this.dio) {
    //dio.options.baseUrl = 'https://lucns.io/apps/monitor_queimadas_cariri/';
    dio.options.baseUrl = 'https://monitorqueimadas.duckdns.org/';
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler requestInterceptorHandler) async {
        if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
          return requestInterceptorHandler.reject(DioException(error: 'Sem conexão! Conecte-se e tente novamente!', requestOptions: options));
        }

        //options.headers['Application-Version'] = Constants.APP_VERSION;
        //options.headers['Application-Version-Code'] = '1000';
        //options.headers['User-Agent'] = 'userAgent';
        return requestInterceptorHandler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler responseInterceptorHandler) async {
        return responseInterceptorHandler.next(response);
      },
    ));
  }

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

class ControllerApi {
  final api = Api(Dio());
  bool recursible = false;

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
