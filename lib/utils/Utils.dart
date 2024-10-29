// @developes by @lucns

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'AppColors.dart';

class Utils {
  static double getWidthDisplay() {
    return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  }

  static double getHeightDisplay() {
    return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
  }

  static Alignment menuPosition(context) {
    double displayHeight = MediaQuery.of(context).size.height;
    double proportionY = 56 / displayHeight; // 56dp = toolbar height
    double b = (proportionY * 2) - 1;
    return Alignment(1, b);
  }

  static Alignment coordinatesToRelative(context, w, h, x, y) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double proportionX = (x + (w / 2)) / displayWidth;
    double proportionY = (y + (h / 2)) / displayHeight;
    double a = (proportionX * 2) - 1;
    double b = (proportionY * 2) - 1;
    return Alignment(a, b);
  }

  static Alignment percentageToRelative(context, w, h, xPercentage, yPercentage) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double x = (xPercentage / 100) * displayWidth;
    double y = (yPercentage / 100) * displayHeight;

    double proportionX = (x) / displayWidth;
    double proportionY = (y) / displayHeight;
    double a = (proportionX * 2) - 1;
    double b = (proportionY * 2) - 1;
    return Alignment(a, b);
  }

  static changeBarsColors(bool inDialog, bool isLoginScreen, Brightness statusBar, Brightness navigationBar) {
    //log("inDialog:$inDialog isDarkTheme:$isDarkTheme isLoginScreen:$isLoginScreen");
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: isLoginScreen ? (inDialog ? AppColors.fragmentBackgroundInDialog : AppColors.fragmentBackground) : (inDialog ? AppColors.appBackgroundInDialog : (AppColors.appBackground)),
        systemNavigationBarColor: isLoginScreen ? (inDialog ? (AppColors.appBackgroundInDialog) : (AppColors.appBackground)) : (inDialog ? (AppColors.fragmentBackgroundInDialog) : (AppColors.fragmentBackground)),
        statusBarIconBrightness: statusBar,
        systemNavigationBarIconBrightness: navigationBar));
  }

  static vibrate() async {
    if (await Vibration.hasAmplitudeControl() ?? false) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    } else {
      Vibration.vibrate(duration: 50);
    }
  }

  static pulsate() async {
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(duration: 50);
    } else {
      Vibration.vibrate(duration: 50);
      await Future.delayed(const Duration(milliseconds: 100));
      Vibration.vibrate(duration: 50);
    }
  }

  static int getRemainderDays() {
    DateTime dateTime = DateTime.now().toLocal();
    DateTime nextYear = DateTime(dateTime.year + 1);
    return nextYear.difference(dateTime).inDays;
  }

  static String getMonthName() {
    DateTime now = DateTime.now().toLocal();
    switch (now.month) {
      case 1:
        return "Janeiro";
      case 2:
        return "Fevereiro";
      case 3:
        return "Março";
      case 4:
        return "Abril";
      case 5:
        return "Maio";
      case 6:
        return "Junho";
      case 7:
        return "Julho";
      case 8:
        return "Agosto";
      case 9:
        return "Setembro";
      case 10:
        return "Outubro";
      case 11:
        return "Novembro";
      default:
        return "Dezembro";
    }
  }

  static Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((item) => item == ConnectivityResult.mobile) || connectivityResult.any((item) => item == ConnectivityResult.wifi);
  }

  static String removeDiacritics(String str) {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }
}
