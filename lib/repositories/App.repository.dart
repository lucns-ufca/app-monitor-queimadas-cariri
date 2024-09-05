// @developes by @lucns

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:dio/dio.dart';

class AppRepository {
  final api = Api(Dio());

  AppRepository();

  Future<ApiResponse> getPredictionValues({String? city}) async {
    try {
      Response response = await api.dio.get('prediction/predictions.php');
      if (response.statusCode == 200) {
        //Prediction prediction = Prediction.fromJson(response.data);
        //return ApiResponse(responseCode: response.statusCode, response: prediction);
      }
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      if (e.response == null) {
        return ApiResponse(message: "O servidor não respondeu. Prazo de espera estourado.", code: ApiResponseCodes.GATEWAY_TIMEOUT);
      } else if (e.response!.statusCode != null) {
        String? message;
        if (e.response!.statusCode == ApiResponseCodes.UNAUTHORIZED) {
          message = "Sem autorização!";
        } else {
          message = Api.getError(e.response!.statusCode!);
        }
        return ApiResponse(message: message, code: e.response!.statusCode);
      }
    }
    return ApiResponse(message: "Erro desconhecido.");
  }

  Future<ApiResponse> reportFire(FormData formData) async {
    try {
      Response response = await api.dio.post('reports/reports.php', data: formData);
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      if (e.response == null) {
        return ApiResponse(message: "O servidor não respondeu. Prazo de espera estourado.", code: ApiResponseCodes.GATEWAY_TIMEOUT);
      } else if (e.response!.statusCode != null) {
        String? message;
        if (e.response!.statusCode == ApiResponseCodes.UNAUTHORIZED) {
          message = "Sem autorização!";
        } else {
          message = Api.getError(e.response!.statusCode!);
        }
        return ApiResponse(message: message, code: e.response!.statusCode);
      }
    }
    return ApiResponse(message: "Erro desconhecido.");
  }
}
