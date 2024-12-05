import 'package:dio/dio.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/WeatherApi.model.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';

class WeatherRepository {
  final controllerApi = ControllerApi(Api(baseUrl: 'https://api.weatherapi.com/'));

  Future<WeatherApiModel?> updateWeather(String city) async {
    String? coordinates = Constants.CITIES_COORDINATES[city];
    if (coordinates == null) {
      return null;
    }
    try {
      Response response = await controllerApi.get('v1/current.json?key=a8856d705d3b4b17b25151225240605&q=$coordinates&aqi=yes');
      return WeatherApiModel().fromJson(response.data);
    } on DioException catch (_) {}
    return null;
  }
}
