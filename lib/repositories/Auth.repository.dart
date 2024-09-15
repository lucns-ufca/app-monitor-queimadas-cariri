// @developes by @lucns

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ControllerApi api = ControllerApi();

  AuthRepository();

  Future<ApiResponse> login(User user) async {
    try {
      Response response = await api.post('auth/login', {"email": user.email, "password": user.password});
      if (response.data["access_token"] == null) {
        return ApiResponse(message: "Não foi possivel realizar o login nesse momento.");
      }
      user.accessToken = response.data["access_token"];
      await user.storeData();

      return ApiResponse(code: ApiResponseCodes.OK);
    } on DioException catch (e) {
      if (e.response == null) {
        return ApiResponse(message: "O servidor não respondeu. Prazo de espera estourado.", code: ApiResponseCodes.GATEWAY_TIMEOUT);
      } else if (e.response!.statusCode != null) {
        String? message;
        if (e.response!.statusCode == ApiResponseCodes.UNAUTHORIZED) {
          message = "Email ou senha errados!";
        } else {
          message = Api.getError(e.response!.statusCode!);
        }
        return ApiResponse(message: message, code: e.response!.statusCode);
      }
    }
    return ApiResponse(message: "Erro desconhecido.");
  }

  Future<ApiResponse> createAccount(User user) async {
    try {
      await api.post('admins', {"username": user.name, "email": user.email, "password": user.password});
      return ApiResponse(code: ApiResponseCodes.OK);
    } on DioException catch (e) {
      if (e.response == null) {
        return ApiResponse(message: "O servidor não respondeu. Prazo de espera estourado.", code: ApiResponseCodes.GATEWAY_TIMEOUT);
      } else if (e.response!.statusCode != null) {
        String? message;
        if (e.response!.statusCode == ApiResponseCodes.CONFLIT) {
          message = "Este email já está cadastrado! Tente um diferente.";
        } else {
          message = Api.getError(e.response!.statusCode!);
        }
        return ApiResponse(message: message, code: e.response!.statusCode);
      }
    }
    return ApiResponse(message: "Erro desconhecido.");
  }

  Future<ApiResponse> getUserType(String email) async {
    try {
      Response response = await api.post('/users/user_type.php', {"email": email});
      return ApiResponse(code: ApiResponseCodes.OK, data: response.data);
    } on DioException catch (e) {
      if (e.response == null) {
        return ApiResponse(message: "O servidor não respondeu. Prazo de espera estourado.", code: ApiResponseCodes.GATEWAY_TIMEOUT);
      } else if (e.response!.statusCode != null) {
        String message = Api.getError(e.response!.statusCode!);
        return ApiResponse(message: message, code: e.response!.statusCode);
      }
    }
    return ApiResponse(message: "Erro desconhecido.");
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
