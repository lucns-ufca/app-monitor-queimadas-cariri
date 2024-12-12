// @developes by @lucns

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/FireOccurrence.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
//import 'package:path_provider/path_provider.dart';

class BdQueimadasRepository {
  Api api = Api(baseUrl: 'https://terrabrasilis.dpi.inpe.br/');
  late ControllerApi controllerApi;
  Map<String, dynamic> cities = {};
  String csrf = "ySRCjAhp-E3o9U06aJioHbX3SZKczvFNN7hE";
  String cookie = "_csrf=OUAZnDlWF34ND-ZzHLylZNpw";
  void Function()? onUpdateConcluded, onUpdate, onFailure;
  int updateCounter = 0;
  Map<String, dynamic> CITIES_IDS = {
    'Salitre': '033232311959',
    'Campos Sales': '033232302701',
    'Araripe': '033232301307',
    'Potengi': '033232311207',
    'Assaré': '033232301604',
    'Antonina do Norte': '033232300804',
    'Tarrafas': '033232313252',
    'Altaneira': '033232300606',
    'Nova Olinda': '033232309201',
    'Santana do Cariri': '033232312106',
    'Farias Brito': '033232304301',
    'Crato': '033232304202',
    'Juazeiro do Norte': '033232307304',
    'Barbalha': '033232301901',
    'Jardim': '033232307106',
    'Porteiras': '033232311108',
    'Penaforte': '033232310605',
    'Jati': '033232307205',
    'Brejo Santo': '033232302503',
    'Abaiara': '033232300101',
    'Milagres': '033232308302',
    'Mauriti': '033232308104',
    'Barro': '033232302008',
    'Caririaçu': '033232303204',
    'Granjeiro': '033232304806',
    'Aurora': '033232301703',
    'Lavras da Mangabeira': '033232307502',
    'Ipaumirim': '033232305704',
    'Baixio': '033232301802',
    'Umari': '033232313708'
  };
  Map<String, dynamic> occurrences = {};

  BdQueimadasRepository() {
    controllerApi = ControllerApi(api);
  }

  void setOnUpdateListener(void Function()? onUpdate, void Function()? onUpdateConcluded, void Function()? onFailure) {
    this.onUpdate = onUpdate;
    this.onUpdateConcluded = onUpdateConcluded;
    this.onFailure = onFailure;
  }

  Future<void> update() async {
    if (!await requestCookies()) {
      if (onFailure != null) onFailure!();
      return;
    }

    DateTime now = DateTime.now().toLocal();
    //DateTime before = DateTime.now().toLocal();
    DateTime before = now.subtract(const Duration(hours: 24)).toLocal();
    String fromMonth, fromDay, toMonth, toDay;
    if (before.day < 10) {
      fromDay = '0${before.day}';
    } else {
      fromDay = '${before.day}';
    }
    if (before.month < 10) {
      fromMonth = '0${before.month}';
    } else {
      fromMonth = '${before.month}';
    }
    if (now.day < 10) {
      toDay = '0${now.day}';
    } else {
      toDay = '${now.day}';
    }
    if (now.month < 10) {
      toMonth = '0${now.month}';
    } else {
      toMonth = '${now.month}';
    }

    String from = "${before.year}-$fromMonth-$fromDay";
    String to = "${now.year}-$toMonth-$toDay";
    //log("from: $from to $to");
    occurrences.clear();
    updateCounter = 0;
    CITIES_IDS.forEach((key, value) async {
      generateRequest(value, key, from, to);
      await Future.delayed(const Duration(milliseconds: 100));
    });
  }

  Future<bool> requestCookies() async {
    try {
      Response response = await controllerApi.get('queimadas/bdqueimadas/');
      if (response.statusCode == 200) {
        String value = response.headers.value("set-cookie")!;
        cookie = value.substring(0, value.indexOf(';'));
        String html = response.data as String;
        for (String line in html.split('\n')) {
          if (line.contains('_csrf')) {
            csrf = line.substring(line.lastIndexOf('_csrf') + 14, line.length - 2);
            break;
          }
        }
        api.addHeaders({'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'X-CSRF-Token': csrf, 'Cookie': cookie});
        return true;
      }
    } on DioException catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>?> requestOccurrences(String cityId, String from, String to) async {
    try {
      Response response = await controllerApi.post('queimadas/bdqueimadas/get-attributes-table', getData(cityId, from, to));
      return response.data;
    } on DioException catch (_) {}
    return null;
  }

  String getData(String city, String dateFrom, String dateTo) {
    return "draw=2&columns%5B0%5D%5Bdata%5D=0&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=true&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=1&columns%5B1%5D%5Bname%5D=&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=2&columns%5B2%5D%5Bname%5D=&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=3&columns%5B3%5D%5Bname%5D=&columns%5B3%5D%5Bsearchable%5D=true&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=4&columns%5B4%5D%5Bname%5D=&columns%5B4%5D%5Bsearchable%5D=true&columns%5B4%5D%5Borderable%5D=true&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B5%5D%5Bdata%5D=5&columns%5B5%5D%5Bname%5D=&columns%5B5%5D%5Bsearchable%5D=true&columns%5B5%5D%5Borderable%5D=true&columns%5B5%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B5%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B6%5D%5Bdata%5D=6&columns%5B6%5D%5Bname%5D=&columns%5B6%5D%5Bsearchable%5D=true&columns%5B6%5D%5Borderable%5D=true&columns%5B6%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B6%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B7%5D%5Bdata%5D=7&columns%5B7%5D%5Bname%5D=&columns%5B7%5D%5Bsearchable%5D=true&columns%5B7%5D%5Borderable%5D=true&columns%5B7%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B7%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B8%5D%5Bdata%5D=8&columns%5B8%5D%5Bname%5D=&columns%5B8%5D%5Bsearchable%5D=true&columns%5B8%5D%5Borderable%5D=true&columns%5B8%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B8%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B9%5D%5Bdata%5D=9&columns%5B9%5D%5Bname%5D=&columns%5B9%5D%5Bsearchable%5D=true&columns%5B9%5D%5Borderable%5D=true&columns%5B9%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B9%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B10%5D%5Bdata%5D=10&columns%5B10%5D%5Bname%5D=&columns%5B10%5D%5Bsearchable%5D=true&columns%5B10%5D%5Borderable%5D=true&columns%5B10%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B10%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B11%5D%5Bdata%5D=11&columns%5B11%5D%5Bname%5D=&columns%5B11%5D%5Bsearchable%5D=true&columns%5B11%5D%5Borderable%5D=true&columns%5B11%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B11%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B12%5D%5Bdata%5D=12&columns%5B12%5D%5Bname%5D=&columns%5B12%5D%5Bsearchable%5D=true&columns%5B12%5D%5Borderable%5D=true&columns%5B12%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B12%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=desc&start=0&length=100&search%5Bvalue%5D=&search%5Bregex%5D=false&dateTimeFrom=$dateFrom+00%3A00%3A00&dateTimeTo=$dateTo+23%3A59%3A59&satellites=AQUA_M-T&biomes=&continent=8&countries=33&states=03323&cities=$city&specialRegions=&protectedArea=&industrialFires=false";
  }

  void generateRequest(String cityId, String city, String from, String to) async {
    Map<String, dynamic>? map = await requestOccurrences(cityId, from, to);
    Map<String, dynamic> o = {};
    if (map != null) {
      for (List<dynamic> list in map['data']) {
        String dateTime = list[0];
        o[dateTime] = FireOccurrenceModel(dateTime: dateTime, latitude: list[9], longitude: list[10]);
      }
    }
    List<FireOccurrenceModel> list = [];
    o.forEach((k, v) => list.add(v));
    /*
    List<FireOccurrenceModel> list2 = [];    
    for (FireOccurrenceModel model in list) {
      bool found = false;
      for (FireOccurrenceModel model2 in list2) {
        if ((model.latitude! == model2.latitude! && model.longitude == model2.longitude) || isNearest(model.latitude!, model.longitude!, model2.latitude!, model2.longitude!)) {
          found = true;
          break;
        }
      }
      if (!found) list2.add(model);
    }
    occurrences[city] = list2;
    */
    occurrences[city] = list;
    updateCounter++;
    if (onUpdateConcluded != null) onUpdate!();
    if (updateCounter == CITIES_IDS.length) onUpdateConcluded!();
  }

  Future<void> saveOccurrences() async {
    //Directory directory = await getApplicationDocumentsDirectory();
    //File file = File("${directory.path}/data/occurrences/$city.json");
  }

  Future<void> updateLocal() async {}

  Future<String?> downloadData(String url, String path) async {
    try {
      Response response = await controllerApi.get(url);
      if (response.statusCode == 200) {
        String jsonString = json.encode(response.data["data"]);
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

  Future<void> updateOccurrences() async {
    //Directory directory = await getApplicationDocumentsDirectory();
    //String? data = await downloadData('weather/forecast.php', "${directory.path}/data/weather/AllCitiesForecast.json");
  }

  Future<Response?> getPredictionValues({String? city}) async {
    try {
      return await controllerApi.get('prediction/predictions.php');
    } on DioException catch (e) {
      return e.response;
    }
  }

  bool isNearest(double lat1, double lon1, double lat2, double lon2) {
    double radius = 6371; // earth radius in km
    double dlat = radians(lat2 - lat1);
    double dlon = radians(lon2 - lon1);
    double a = (math.sin(dlat / 2) * math.sin(dlat / 2) + math.cos(radians(lat1)) * math.cos(radians(lat2)) * math.sin(dlon / 2) * math.sin(dlon / 2));
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double d = radius * c;
    return d <= 1;
  }

  double radians(double deg) => deg / 180.0 * 3.1415;
}
