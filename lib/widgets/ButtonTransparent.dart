// @developed by @lucns

import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';

class MyButtonTransparent extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isEnabled;
  final Color color;
  final Function()? onClick;

  const MyButtonTransparent({super.key, required this.text, this.onClick, this.style, this.color = AppColors.buttonNormal, this.isEnabled = true});

  @override
  State<MyButtonTransparent> createState() => _MyButtonTransparentState();
}

class _MyButtonTransparentState extends State<MyButtonTransparent> {
  _MyButtonTransparentState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 220,
        height: 48,
        child: TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(widget.color),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(56), side: const BorderSide(color: Colors.transparent)))),
            onPressed: widget.isEnabled ? widget.onClick : null,
            child: Text(widget.text, style: widget.style ?? TextStyle(fontSize: 16, color: widget.isEnabled ? AppColors.textNormal : AppColors.textDisabled))));
  }
}
