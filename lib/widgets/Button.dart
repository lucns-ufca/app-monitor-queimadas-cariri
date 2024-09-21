// @developed by @lucns

import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';

class MyButton extends StatefulWidget {
  final String textButton;
  final Function()? onClick;
  final Color colorBackground;
  final Color? colorRipple;
  final Color colorDisabled;

  const MyButton({
    this.colorBackground = AppColors.accent,
    this.colorRipple,
    this.colorDisabled = AppColors.buttonDisabled,
    required this.textButton,
    this.onClick,
    super.key,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  double height = Constants.DEFAULT_WIDGET_HEIGHT;

  _MyButtonState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: height,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(widget.onClick == null ? widget.colorDisabled : widget.colorBackground),
              overlayColor: WidgetStateProperty.all<Color>(widget.onClick == null ? Colors.transparent : widget.colorRipple ?? Colors.white.withOpacity(0.5)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 2), side: const BorderSide(color: Colors.transparent)))),
          onPressed: widget.onClick,
          child: Text(widget.textButton, style: TextStyle(color: widget.onClick == null ? AppColors.textDisabled : AppColors.appBackground, fontSize: 18, fontWeight: FontWeight.w500))),
    );
  }
}
