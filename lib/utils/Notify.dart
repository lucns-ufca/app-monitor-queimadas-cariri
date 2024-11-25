import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/TransparentButton.widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Notify {
  static showToast(String text, {bool longTost = false}) {
    Fluttertoast.showToast(msg: text, toastLength: longTost ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, backgroundColor: Color.fromARGB(255, 46, 35, 24), textColor: const Color.fromARGB(255, 255, 148, 16), fontSize: 16);
  }

  static showSnackbarSucess(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showSnackbar(context, duration, AppColors.fragmentBackgroundSuccess, Colors.white, message);
  }

  static showSnackbarError(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showSnackbar(context, duration, AppColors.fragmentBackgroundError, Colors.white, message);
  }

  static showSnackbarInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showSnackbar(context, duration, AppColors.fragmentBackgroundInfo, AppColors.titleDark, message);
  }

  static showSnackbar(BuildContext context, Duration duration, Color colorBackground, Color colorText, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //elevation: 0,
        //behavior: SnackBarBehavior.fixed,
        content: Text(message, style: TextStyle(color: colorText, fontSize: 16, fontWeight: FontWeight.bold)),
        duration: duration,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        backgroundColor: colorBackground,
        /*
        action: SnackBarAction(
          textColor: Color(0xFFFAF2FB),
          label: 'OK',
          onPressed: () {},
        ),
        */
      ),
    );
  }

  static Future<void> showDialogError(BuildContext context, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: 330,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  color: AppColors.accent,
                  Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    height: 1.6,
                    color: AppColors.textNormal,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  child: TransparentButton(
                      text: "OK",
                      onTap: () {
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          );
        });
  }
}
