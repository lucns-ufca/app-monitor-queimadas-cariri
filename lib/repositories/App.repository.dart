// @developes by @lucns

import 'dart:convert';
import 'dart:io';

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/PredictionCity.model.dart';
import 'package:monitor_queimadas_cariri/models/ForecastCity.model.dart';
import 'package:monitor_queimadas_cariri/models/WeatherCity.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRepository {
  final ControllerApi api = ControllerApi(Api(baseUrl: 'https://monitorqueimadas.duckdns.org/'));
  void Function()? onUpdateConcluded;
  void Function(int)? onError;

  List<PredictionCityModel> predictionCities = [];
  List<WeatherCityModel> weatherCities = [];
  List<ForecastCityModel> forecastCities = [];
  bool updatingPrediction = false;
  bool updatingWeather = false;
  bool updatingForecast = false;

  AppRepository();

  List<PredictionCityModel> get getPredictionCities => predictionCities;
  List<WeatherCityModel> get getWeatherCities => weatherCities;
  List<ForecastCityModel> get getForecastCities => forecastCities;

  void setOnUpdateConcluded(void Function() onUpdateConcluded) {
    this.onUpdateConcluded = onUpdateConcluded;
  }

  void setOnError(void Function(int) onError) {
    this.onError = onError;
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
    //await addToforecastCities("${directory.path}/data/weather/AllCitiesForecast.json");
    if (onUpdateConcluded != null) onUpdateConcluded!();
  }

  bool allowUpdatePrediction() {
    if (predictionCities.isEmpty) return true;
    DateTime old = DateTime.parse(predictionCities[0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 60) return true;
    return false;
  }

  bool allowUpdateWeather() {
    if (weatherCities.isEmpty) return true;
    DateTime old = DateTime.parse(weatherCities[0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 15) return true;
    return false;
  }

  bool allowUpdateForecast() {
    if (forecastCities.isEmpty) return true;
    DateTime old = DateTime.parse(forecastCities[0].forecast![0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inDays > 0) return true;
    return false;
  }

  Future<void> updatePrediction(int year) async {
    updatingPrediction = true;
    Directory directory = await getApplicationDocumentsDirectory();
    try {
      String? data = await downloadData('predictions?page=1&limit=30&year=$year', "${directory.path}/data/prediction/AllCitiesPrediction.json");
      if (data == null) {
        updatingPrediction = false;
        if (onError != null) onError!(api.getResponseCode());
        return;
      }
      List<dynamic> jsonArray = jsonDecode(data);
      predictionCities.clear();
      for (dynamic json in jsonArray) {
        predictionCities.add(PredictionCityModel.fromJson(json));
      }
      updatingPrediction = false;
      if (!updatingForecast && !updatingWeather && onUpdateConcluded != null) onUpdateConcluded!();
    } catch (e, t) {
      debugPrintStack(stackTrace: t);
      updatingPrediction = false;
      if (onError != null) onError!(api.getResponseCode());
    }
  }

  Future<void> updateWeather() async {
    updatingWeather = true;
    Directory directory = await getApplicationDocumentsDirectory();
    try {
      String? data = await downloadData('fire-weather-data/search/last', "${directory.path}/data/weather/AllCitiesWeather.json");
      if (data == null) {
        updatingWeather = false;
        if (onError != null) onError!(api.getResponseCode());
        return;
      }
      List<dynamic> jsonArray = jsonDecode(data);
      weatherCities.clear();
      for (Map<String, dynamic> json in jsonArray) {
        weatherCities.add(WeatherCityModel.fromJson(json));
      }
      updatingWeather = false;
      if (!updatingForecast && !updatingPrediction && onUpdateConcluded != null) onUpdateConcluded!();
    } catch (e, t) {
      debugPrintStack(stackTrace: t);
      updatingWeather = false;
      if (onError != null) onError!(api.getResponseCode());
    }
  }

  Future<void> updateforecast() async {
    updatingForecast = true;
    Directory directory = await getApplicationDocumentsDirectory();
    try {
      String? data = await downloadData('weather/forecast.php', "${directory.path}/data/weather/AllCitiesForecast.json");

      if (data == null) {
        updatingForecast = false;
        if (onError != null) onError!(api.getResponseCode());
        return;
      }
      List<dynamic> jsonArray = jsonDecode(data);
      forecastCities.clear();
      for (Map<String, dynamic> json in jsonArray) {
        forecastCities.add(ForecastCityModel.fromJson(json));
      }
      updatingForecast = false;
      if (!updatingWeather && !updatingPrediction && onUpdateConcluded != null) onUpdateConcluded!();
    } catch (e, t) {
      debugPrintStack(stackTrace: t);
      updatingForecast = false;
      if (onError != null) onError!(api.getResponseCode());
    }
  }

  Future<String?> downloadData(String url, String path) async {
    try {
      Response response = await api.get(url);
      if (response.statusCode == 200) {
        String jsonString = json.encode(response.data);
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
    Dio api = Dio(BaseOptions(baseUrl: 'https://monitorqueimadas.duckdns.org/'));
    try {
      Response response = await api.post('warnings', data: formData);
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String ip = preferences.getString("ip") ?? "";
    String port = preferences.getString("port") ?? "";
    bool useLocal = preferences.getBool("use_local") ?? false;
    String baseUrl = useLocal && ip.isNotEmpty && port.isNotEmpty ? 'http://$ip:$port/' : 'https://lucns.io/apps/monitor_queimadas_cariri/';
    Dio api = Dio(BaseOptions(baseUrl: baseUrl));
    try {
      Response response = await api.post('warnings', data: json);
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
        message = ControllerApi.getError(e.response!.statusCode!);
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
