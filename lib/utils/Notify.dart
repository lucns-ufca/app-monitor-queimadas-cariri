import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Notify {
  static showToast(String text, {bool longTost = false}) {
    Fluttertoast.showToast(msg: text, toastLength: longTost ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, backgroundColor: AppColors.fragmentBackground, textColor: Colors.white, fontSize: 16.0);
  }

  static showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Sending Message",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    ));
  }
}
