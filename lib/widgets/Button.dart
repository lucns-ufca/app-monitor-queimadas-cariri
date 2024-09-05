// @developed by @lucns

import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';

class MyButton extends StatefulWidget {
  final String textButton;
  final bool isNegative;
  final Function()? onClick;

  const MyButton({super.key, this.isNegative = false, required this.textButton, this.onClick});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  _MyButtonState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 36,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(widget.isNegative ? AppColors.buttonNegative : AppColors.buttonPositive),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                return widget.onClick == null ? Colors.transparent : Colors.white.withOpacity(0.3);
              }),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(56), side: const BorderSide(color: Colors.transparent)))),
          onPressed: widget.onClick,
          child: Text(widget.textButton, style: TextStyle(color: widget.onClick == null ? AppColors.textDisabled : AppColors.white, fontSize: 18, fontWeight: FontWeight.w500))),
    );
  }
}
