import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Api {
  final Dio dio;

  Api(this.dio) {
    //dio.options.baseUrl = 'https://mmonitorqueimadasbackend.onrender.com/';
    dio.options.baseUrl = 'https://lucns.io/apps/monitor_queimadas_cariri/';
    dio.options.connectTimeout = const Duration(seconds: 300);
    dio.options.receiveTimeout = const Duration(seconds: 300);
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
