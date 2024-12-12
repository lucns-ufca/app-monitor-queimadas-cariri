import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:monitor_queimadas_cariri/api/Api.dart';
import 'package:monitor_queimadas_cariri/api/Controller.api.dart';
import 'package:monitor_queimadas_cariri/models/FireAlert.model.dart';

class AlertsRepository {
  final ControllerApi api = ControllerApi(Api(baseUrl: 'https://monitorqueimadas.duckdns.org/'));
  void Function(int)? onError;

  void setOnError(void Function(int) onError) {
    this.onError = onError;
  }

  Future<List<FireAlertModel>?> getPendingAlerts() async {
    return await getAlertsPerType(ValidationType.PENDING);
  }

  Future<List<FireAlertModel>?> getInvalidAlerts() async {
    return await getAlertsPerType(ValidationType.INVALID);
  }

  Future<List<FireAlertModel>?> getValidatedAlerts() async {
    return await getAlertsPerType(ValidationType.VALIDATED);
  }

  Future<List<FireAlertModel>?> getAlertsPerType(ValidationType validationType) async {
    String type;
    switch (validationType) {
      case ValidationType.VALIDATED:
        type = 'VALIDATED';
        break;
      case ValidationType.INVALID:
        type = 'INVALID';
        break;
      default:
        type = 'PENDING';
        break;
    }
    try {
      Response response = await api.get('warnings', parameters: {'page': 1, 'limit': 10, 'status': type});
      if (response.statusCode == 200) {
        List<FireAlertModel> models = [];
        for (dynamic d in response.data['data']) {
          models.add(FireAlertModel.fromJson(d));
        }
        return models;
      }
    } catch (e, t) {
      debugPrintStack(stackTrace: t);
      if (onError != null) onError!(api.getResponseCode());
    }
    return null;
  }
}

enum ValidationType { VALIDATED, INVALID, PENDING }
