import 'package:intl/intl.dart';

class NewsModel {
  String? title, description;
  int priority = 0;
  String date = DateFormat('Hoje às kk:mm').format(DateTime.now().toLocal());
  String? assetsIcon;
}
