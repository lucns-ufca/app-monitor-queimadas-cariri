import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BaseWidgets {
  Widget getCenteredloading(String text) {
    return Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 3,
                  )),
              const SizedBox(width: 16),
              Text(text, style: const TextStyle(color: Colors.white))
            ])));
  }

  Widget getCenteredError(String text) {
    return Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset("assets/icons/alert.svg", width: 16, height: 16), const SizedBox(width: 8), Text(text, style: const TextStyle(color: AppColors.red))])));
  }
}
