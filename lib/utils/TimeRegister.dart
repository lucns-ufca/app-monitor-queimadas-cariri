import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Timeregister {
  final String name;
  const Timeregister(this.name);

  Future<void> setLastUpodate() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/$name");
    await file.writeAsString(DateTime.now().toLocal().toIso8601String());
  }

  Future<bool> hasRegister() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/$name").exists();
  }

  Future<int> getLeavingMinutes() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/$name");
    if (await file.exists()) {
      DateTime lastUpdate = DateTime.parse(await file.readAsString());
      Duration difference = DateTime.now().toLocal().difference(lastUpdate);
      return difference.inMinutes;
    }
    return 0;
  }

  Future<bool> isOverTime(int minutes) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/$name");
    if (await file.exists()) {
      DateTime lastUpdate = DateTime.parse(await file.readAsString());
      Duration difference = DateTime.now().toLocal().difference(lastUpdate);
      return difference.inMinutes > minutes;
    }
    return true;
  }

  Future<String> getLastUpdate() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/$name");
    if (await file.exists()) {
      DateTime lastUpdate = DateTime.parse(await file.readAsString());
      Duration difference = DateTime.now().toLocal().difference(lastUpdate);
      if (difference.inDays > 1) {
        return "Atualizado em ${DateFormat('dd/MM/yyyy às kk:mm').format(lastUpdate)}";
      } else if (difference.inDays == 1) {
        return "Atualizado ontem às ${DateFormat('kk:mm').format(lastUpdate)}";
      } else {
        return "Atualizado hoje às ${DateFormat('kk:mm').format(lastUpdate)}";
      }
    }
    return "Nunca atualizado";
  }

  Future<void> delete() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    await File("${directory.path}/$name").delete();
  }
}
