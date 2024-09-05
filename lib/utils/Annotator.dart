// Developed vy @lucns

import 'dart:io';

import 'package:get_it/get_it.dart';

class Annotator {
  final String defaultFile;
  String? relativePath;
  Directory directory = GetIt.I.get<Directory>();

  Annotator(this.relativePath) : defaultFile = "data.txt";

  bool exists() {
    return File("${directory.path}/${relativePath ?? defaultFile}").existsSync();
  }

  void setRelativePath(String relativePath) {
    this.relativePath = relativePath;
  }

  Future<void> delete() async {
    await File("${directory.path}/${relativePath ?? defaultFile}").delete();
  }

  Future<void> setContent(String text) async {
    final File file = File("${directory.path}/${relativePath ?? defaultFile}");
    await file.writeAsString(text);
  }

  Future<String> getContent() async {
    if (exists()) {
      return await File(getPath()).readAsString();
    }
    return "";
  }

  String getPath() {
    return "${directory.path}/${relativePath ?? defaultFile}";
  }
}
