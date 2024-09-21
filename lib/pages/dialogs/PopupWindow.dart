// @Developed by @lucns

//import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:app_monitor_queimadas/utils/AppColors.dart';

class PopupWindow {
  final BuildContext context;
  AlignmentGeometry? position;
  final bool isCancelable;

  PopupWindow({required this.context, this.position, required this.isCancelable});

  void dismiss() {
    Navigator.pop(context);
  }

  void showWindow(Widget content) {
    showDialog(
      barrierDismissible: isCancelable,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Align(
            alignment: position ?? Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.menuBackground,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: content,
            ));
      },
    );
  }
}

//const CircularProgressIndicator(color: AppColors.textEnabled)
