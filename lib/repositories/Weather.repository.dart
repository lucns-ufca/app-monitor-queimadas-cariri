import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';

class WeatherRepository {
  final controllerApi = ControllerApi(Api(baseUrl: 'https://terrabrasilis.dpi.inpe.br/'));
  Map<String, dynamic> cities = {};
}
