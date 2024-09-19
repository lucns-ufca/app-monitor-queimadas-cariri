import 'package:intl/intl.dart';

class BaseModel {
  String? title, description;
  int priority = 0;
  String date = DateFormat('Hoje às kk:mm').format(DateTime.now().toLocal());
}
