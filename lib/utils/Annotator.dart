// Developed vy @lucns

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Annotator {
  final String defaultFile;
  String? relativePath;

  Annotator(this.relativePath) : defaultFile = "data.txt";

  Future<bool> exists() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return await File("${directory.path}/${relativePath ?? defaultFile}").exists();
  }

  void setRelativePath(String relativePath) {
    this.relativePath = relativePath;
  }

  Future<void> delete() async {
    Directory directory = await getApplicationDocumentsDirectory();
    await File("${directory.path}/${relativePath ?? defaultFile}").delete();
  }

  Future<void> setContent(String text) async {
    Directory directory = await getApplicationDocumentsDirectory();
    final File file = File("${directory.path}/${relativePath ?? defaultFile}");
    await file.writeAsString(text);
  }

  Future<String> getContent() async {
    if (await exists()) {
      return await File(await getPath()).readAsString();
    }
    return "";
  }

  Future<String> getPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/${relativePath ?? defaultFile}";
  }
}
