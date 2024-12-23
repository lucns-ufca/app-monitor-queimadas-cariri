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

class AppRepository {
  final ControllerApi api = ControllerApi(Api(baseUrl: 'https://monitorqueimadas.duckdns.org/'));

  List<PredictionCityModel> predictionCities = [];
  List<WeatherCityModel> weatherCities = [];
  List<ForecastCityModel> forecastCities = [];
  bool updatingPrediction = false;
  bool updatingWeather = false;
  bool updatingForecast = false;
  List<Function> listeners = [];
  void Function(int)? onError;

  AppRepository();

  List<PredictionCityModel> get getPredictionCities => predictionCities;
  List<WeatherCityModel> get getWeatherCities => weatherCities;
  List<ForecastCityModel> get getForecastCities => forecastCities;

  void addUpdateListener(void Function(int?) onUpdate) {
    listeners.add(onUpdate);
  }

  void setOnErrorListener(void Function(int?) onError) {
    this.onError = onError;
  }

  void _onUpdate({int? errorCode}) {
    for (Function f in listeners) {
      f(errorCode);
    }
  }

  Future<void> addToPredictionCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    List<dynamic> jsonArray = jsonDecode(jsonString)['data'];
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
    for (WeatherCityModel m in weatherCities) {
      if (m.city == "Assare") m.city = "Assaré";
      if (m.city == "Caririacu") m.city = "Caririaçu";
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
    _onUpdate();
  }

  bool allowUpdatePrediction() {
    if (predictionCities.isEmpty) return true;
    DateTime old = DateTime.parse(predictionCities[0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    return today.difference(old).inMinutes > 60;
  }

  bool allowUpdateWeather() {
    if (weatherCities.isEmpty) return true;
    DateTime old = DateTime.parse(weatherCities[0].dateTime!);
    DateTime today = DateTime.now();
    if (today.difference(old).inMinutes > 15) return true;
    return false;
  }

  bool allowUpdateForecast() {
    if (forecastCities.isEmpty) return true;
    DateTime old = DateTime.parse(forecastCities[0].forecast![0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    return today.difference(old).inDays > 0;
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
      List<dynamic> jsonArray = jsonDecode(data)['data'];
      if (jsonArray.isEmpty) {
        updatingPrediction = false;
        if (onError != null) onError!(0);
        return;
      }
      predictionCities.clear();
      for (dynamic json in jsonArray) {
        predictionCities.add(PredictionCityModel.fromJson(json));
      }
      updatingPrediction = false;
      if (!updatingForecast && !updatingWeather) _onUpdate();
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
      if (jsonArray.isEmpty) {
        updatingWeather = false;
        if (onError != null) onError!(0);
        return;
      }
      weatherCities.clear();
      for (Map<String, dynamic> json in jsonArray) {
        weatherCities.add(WeatherCityModel.fromJson(json));
      }
      for (WeatherCityModel m in weatherCities) {
        if (m.city == "Assare") m.city = "Assaré";
        if (m.city == "Caririacu") m.city = "Caririaçu";
      }
      updatingWeather = false;
      if (!updatingForecast && !updatingPrediction) _onUpdate();
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
      if (!updatingWeather && !updatingPrediction) _onUpdate();
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

  Future<Response?> reportFireFormData(FormData formData) async {
    try {
      return await api.post('warnings', formData);
    } on DioException catch (e) {
      return e.response;
    }
  }
}
