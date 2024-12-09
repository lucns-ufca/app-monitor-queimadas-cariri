import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Api {
  final Dio dio = Dio();
  final String baseUrl;
  int responsecode = 0;

  Api({this.baseUrl = ""}) {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler requestInterceptorHandler) async {
      if (!await hasInternetConnection()) {
        return requestInterceptorHandler.reject(DioException(error: 'Sem conexão! Conecte-se e tente novamente!', requestOptions: options));
      }

      //options.headers['Application-Version'] = Constants.APP_VERSION;
      //options.headers['Application-Version-Code'] = '1000';
      options.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
      return requestInterceptorHandler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler responseInterceptorHandler) async {
      return responseInterceptorHandler.next(response);
    }, onError: (dioError, interceptor) {
      if (dioError.response == null) {
        responsecode = 0;
      } else {
        responsecode = dioError.response!.statusCode!;
      }
      return interceptor.next(dioError);
    }));
  }

  Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((item) => item == ConnectivityResult.mobile) || connectivityResult.any((item) => item == ConnectivityResult.wifi);
  }

  int getResponseCode() {
    return responsecode;
  }

  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  void addHeaders(Map<String, dynamic> headers) {
    headers.forEach((key, value) {
      dio.options.headers[key] = value;
    });
  }
}
