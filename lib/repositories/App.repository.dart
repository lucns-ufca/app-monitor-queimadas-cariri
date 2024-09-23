// @developes by @lucns

import 'dart:convert';
import 'dart:io';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/PredictionCity.model.dart';
import 'package:app_monitor_queimadas/models/ForecastCity.model.dart';
import 'package:app_monitor_queimadas/models/WeatherCity.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRepository {
  var preferences = GetIt.I.get<SharedPreferences>();
  final ControllerApi api = ControllerApi();
  void Function()? onUpdateConcluded;

  List<PredictionCityModel> predictionCities = [];
  List<WeatherCityModel> weatherCities = [];
  List<ForecastCityModel> forecastCities = [];

  AppRepository();

  List<PredictionCityModel> get getPredictionCities => predictionCities;
  List<WeatherCityModel> get getWeatherCities => weatherCities;
  List<ForecastCityModel> get getForecastCities => forecastCities;

  void setOnUpdateConcluded(void Function()? onUpdateConcluded) {
    this.onUpdateConcluded = onUpdateConcluded;
  }

  Future<void> addToPredictionCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    List<dynamic> jsonArray = jsonDecode(jsonString);
    predictionCities.clear();
    for (dynamic json in jsonArray) {
      predictionCities.add(PredictionCityModel.fromJson(json));
    }
  }

  Future<void> addToWeatherCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    List<dynamic> jsonArray = jsonDecode(jsonString);
    weatherCities.clear();
    for (dynamic json in jsonArray) {
      weatherCities.add(WeatherCityModel.fromJson(json));
    }
  }

  Future<void> addToforecastCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    List<dynamic> jsonArray = jsonDecode(jsonString);
    forecastCities.clear();
    for (Map<String, dynamic> json in jsonArray) {
      forecastCities.add(ForecastCityModel.fromJson(json));
    }
  }

  Future<void> updateLocal() async {
    Directory directory = await getApplicationDocumentsDirectory();
    await addToPredictionCities("${directory.path}/data/prediction/AllCitiesPrediction.json");
    await addToWeatherCities("${directory.path}/data/weather/AllCitiesWeather.json");
    await addToforecastCities("${directory.path}/data/weather/AllCitiesForecast.json");
  }

  bool allowUpdatePrediction() {
    if (predictionCities.isEmpty) return true;
    DateTime old = DateTime.parse(predictionCities[0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 70) return true;
    return false;
  }

  bool allowUpdateWeather() {
    if (weatherCities.isEmpty) return true;
    DateTime old = DateTime.parse(weatherCities[0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 20) return true;
    return false;
  }

  bool allowUpdateForecast() {
    if (forecastCities.isEmpty) return true;
    DateTime old = DateTime.parse(forecastCities[0].forecast![0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inDays > 0) return true;
    return false;
  }

  Future<String?> downloadData(String url, String path) async {
    try {
      Response response = await api.get(url);
      if (response.statusCode == 200) {
        String jsonString = response.data;
        File file = File(path);
        await file.create(recursive: true);
        await file.writeAsString(jsonString);
        return jsonString;
      }
    } catch (e, stacktrace) {
      debugPrintStack(stackTrace: stacktrace);
    }
    return null;
  }

  Future<void> updatePrediction() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String? data = await downloadData('prediction/predictions.php', "${directory.path}/data/prediction/AllCitiesPrediction.json");
    if (data == null) return;
    List<dynamic> jsonArray = jsonDecode(data);
    predictionCities.clear();
    for (dynamic json in jsonArray) {
      predictionCities.add(PredictionCityModel.fromJson(json));
    }
  }

  Future<void> updateWeather() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String? data = await downloadData('weather/weather.php', "${directory.path}/data/weather/AllCitiesWeather.json");
    if (data == null) return;
    List<dynamic> jsonArray = jsonDecode(data);
    weatherCities.clear();
    for (Map<String, dynamic> json in jsonArray) {
      weatherCities.add(WeatherCityModel.fromJson(json));
    }
  }

  Future<void> updateforecast() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String? data = await downloadData('weather/forecast.php', "${directory.path}/data/weather/AllCitiesForecast.json");

    if (data == null) return;
    List<dynamic> jsonArray = jsonDecode(data);
    forecastCities.clear();
    for (Map<String, dynamic> json in jsonArray) {
      forecastCities.add(ForecastCityModel.fromJson(json));
    }
  }

  Future<ApiResponse> getPredictionValues({String? city}) async {
    try {
      Response response = await api.get('prediction/predictions.php');
      if (response.statusCode == 200) {
        //Prediction prediction = Prediction.fromJson(response.data);
        //return ApiResponse(responseCode: response.statusCode, response: prediction);
      }
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return _getDefaultErrorResponse(e);
    }
  }

  Future<ApiResponse> reportFireFormData(FormData formData) async {
    String ip = preferences.getString("ip") ?? "";
    String port = preferences.getString("port") ?? "";
    bool useLocal = preferences.getBool("use_local") ?? false;
    String baseUrl = useLocal && ip.isNotEmpty && port.isNotEmpty ? "'http://$ip:$port/'" : 'https://lucns.io/apps/monitor_queimadas_cariri/';
    Dio api = Dio(BaseOptions(baseUrl: baseUrl));
    try {
      Response response = await api.post('warnings/create', data: formData);
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return _getDefaultErrorResponse(e);
    }
    /*
      try {
        Response response = await api.post('reports/reports.php', formData);
        return ApiResponse(code: response.statusCode, data: response.data);
      } on DioException catch (e) {
        return _getDefaultErrorResponse(e);
      }
      */
  }

  Future<ApiResponse> reportFireJson(Map<String, dynamic> json) async {
    String ip = preferences.getString("ip") ?? "";
    String port = preferences.getString("port") ?? "";
    bool useLocal = preferences.getBool("use_local") ?? false;
    String baseUrl = useLocal && ip.isNotEmpty && port.isNotEmpty ? 'http://$ip:$port/' : 'https://lucns.io/apps/monitor_queimadas_cariri/';
    Dio api = Dio(BaseOptions(baseUrl: baseUrl));
    try {
      Response response = await api.post('warnings/create', data: json);
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return _getDefaultErrorResponse(e);
    }
    /*
      try {
        Response response = await api.post('reports/reports.php', formData);
        return ApiResponse(code: response.statusCode, data: response.data);
      } on DioException catch (e) {
        return _getDefaultErrorResponse(e);
      }
      */
  }

  ApiResponse _getDefaultErrorResponse(DioException e) {
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
    return ApiResponse();
  }
}

abstract class ResponseCallback {
  void onforecastAvailable(List<ForecastCityModel>? value);
  void onWeathersAvailable(List<WeatherCityModel>? value);
  void onPredictionsAvailable(List<PredictionCityModel>? value);
}
