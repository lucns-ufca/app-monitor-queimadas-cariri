import 'package:dio/dio.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/models/WeatherApi.model.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';

class WeatherRepository {
  final api = Api(baseUrl: 'https://api.weatherapi.com/');

  Future<WeatherApiModel?> updateWeather(String city) async {
    String coordinates = "${Constants.CITIES_DATA[city].latitude},${Constants.CITIES_DATA[city].longitude}";
    try {
      Response response = await api.dio.get('v1/current.json?key=a8856d705d3b4b17b25151225240605&q=$coordinates&aqi=yes');
      return WeatherApiModel().fromJson(response.data);
    } on DioException catch (_) {}
    return null;
  }
}
