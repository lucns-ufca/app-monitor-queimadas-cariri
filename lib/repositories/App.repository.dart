// @developes by @lucns

import 'dart:convert';
import 'dart:io';

import 'package:app_monitor_queimadas/api/Api.dart';
import 'package:app_monitor_queimadas/models/PredictionCity.model.dart';
import 'package:app_monitor_queimadas/models/ProbabilityCity.model.dart';
import 'package:app_monitor_queimadas/models/WeatherCity.model.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppRepository {
  final ControllerApi api = ControllerApi();
  List<PredictionCityModel>? predictionCities;
  List<WeatherCityModel>? weatherCities;
  List<ProbabilityCityModel>? probabilitiesCities;

  AppRepository({this.predictionCities, this.probabilitiesCities, this.weatherCities});

  List<PredictionCityModel>? get getPredictionCities => predictionCities;
  List<WeatherCityModel>? get getWeatherCities => weatherCities;
  List<ProbabilityCityModel>? get getProbabilityCities => probabilitiesCities;

  Future<void> addToPredictionCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    PredictionCityModel model = PredictionCityModel.fromJson(jsonDecode(jsonString));
    predictionCities!.add(model);
  }

  Future<void> addToWeatherCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    WeatherCityModel model = WeatherCityModel.fromJson(jsonDecode(jsonString));
    weatherCities!.add(model);
  }

  Future<void> addToProbabilitiesCities(String path) async {
    File file = File(path);
    if (!await file.exists()) return;
    String jsonString = await file.readAsString();
    ProbabilityCityModel model = ProbabilityCityModel.fromJson(jsonDecode(jsonString));
    probabilitiesCities!.add(model);
  }

  Future<void> updateLocal() async {
    Directory directory = await getApplicationDocumentsDirectory();
    if (predictionCities == null) {
      for (String cityName in Constants.CITIES_COORDINATES.keys) {
        String cityWithoutAccents = Utils.removeDiacritics(cityName);
        await addToPredictionCities("${directory.path}/data/prediction/$cityWithoutAccents.json");
        await addToWeatherCities("${directory.path}/data/weather/$cityWithoutAccents.json");
        await addToProbabilitiesCities("${directory.path}/data/probabilities/$cityWithoutAccents.json");
      }
      await addToPredictionCities("${directory.path}/data/prediction/Chapada do Araripe.json");
      await addToWeatherCities("${directory.path}/data/weather/Chapada do Araripe.json");
      await addToProbabilitiesCities("${directory.path}/data/probabilities/Chapada do Araripe.json");
    }
  }

  Future<bool> allowUpdatePrediction() async {
    if (predictionCities == null) return true;
    DateTime old = DateTime.parse(predictionCities![0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 70) return true;
    return false;
  }

  Future<bool> allowUpdateWeather() async {
    if (weatherCities == null) return true;
    DateTime old = DateTime.parse(weatherCities![0].dateTime!).toLocal();
    DateTime today = DateTime.now().toLocal();
    if (today.difference(old).inMinutes > 20) return true;
    return false;
  }

  Future<bool> allowUpdateProbability() async {
    if (probabilitiesCities == null) return true;
    DateTime old = DateTime.parse(probabilitiesCities![0].probabilities![0].dateTime!).toLocal();
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
    List<PredictionCityModel> list = [];
    Directory directory = await getApplicationDocumentsDirectory();
    for (String cityName in Constants.CITIES_COORDINATES.keys) {
      String cityWithoutAccents = Utils.removeDiacritics(cityName);
      String stringEncooded = Uri.encodeComponent(cityWithoutAccents);
      String? data = await downloadData('prediction/predictions.php?city=$stringEncooded', "${directory.path}/data/prediction/$cityWithoutAccents.json");
      if (data == null) continue;
      PredictionCityModel predictionCityModel = PredictionCityModel.fromJson(jsonDecode(data));
      list.add(predictionCityModel);
      await Future.delayed(const Duration(milliseconds: 250));
    }
    predictionCities = list;
    String stringEncooded = Uri.encodeComponent("Chapada do Araripe");
    String? data = await downloadData('prediction/predictions.php?city=$stringEncooded', "${directory.path}/data/prediction/Chapada do Araripe.json");
    if (data == null) return;
    PredictionCityModel predictionCityModel = PredictionCityModel.fromJson(jsonDecode(data));
    list.add(predictionCityModel);
    predictionCities = list;
  }

  Future<void> updateWeather() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String? data = await downloadData('weather/weather.php', "${directory.path}/data/weather/WeatherData.json");
    if (data == null) return;
    List<dynamic> jsonArray = jsonDecode(data);
    List<WeatherCityModel> list = [];
    for (Map<String, dynamic> json in jsonArray) {
      list.add(WeatherCityModel.fromJson(json));
    }
    weatherCities = list;
  }

  Future<void> updateProbabilities() async {
    List<ProbabilityCityModel> list = [];
    Directory directory = await getApplicationDocumentsDirectory();
    String? data = await downloadData('weather/probabilities.php', "${directory.path}/data/weather/ProbabilityData.json");

    if (data == null) return;
    List<dynamic> jsonArray = jsonDecode(data);
    for (Map<String, dynamic> json in jsonArray) {
      list.add(ProbabilityCityModel.fromJson(json));
    }
    probabilitiesCities = list;
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

  Future<ApiResponse> reportFire(FormData formData) async {
    try {
      Response response = await api.post('reports/reports.php', formData);
      return ApiResponse(code: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return _getDefaultErrorResponse(e);
    }
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
  void onProbabilitiesAvailable(List<ProbabilityCityModel>? value);
  void onWeathersAvailable(List<WeatherCityModel>? value);
  void onPredictionsAvailable(List<PredictionCityModel>? value);
}
