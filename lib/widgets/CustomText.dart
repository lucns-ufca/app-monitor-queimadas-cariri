// @developed by @lucns

import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';

class MyText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isEnabled;
  final Function()? onClick;
  final TextController? controller;

  MyText({Key? key, required this.text, this.style, this.textAlign, this.overflow, this.maxLines, this.onClick, this.isEnabled = true, this.controller}) : super(key: key);

  @override
  State<MyText> createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  String? text;
  _MyTextState();

  void setText(String text) {
    setState(() {
      this.text = text;
    });
  }

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.setText = setText;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onClick,
        child: Text(
          text ?? widget.text,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          style: widget.style ?? TextStyle(color: widget.isEnabled ? AppColors.textNormal : AppColors.textDisabled, fontSize: 14, fontWeight: FontWeight.w300),
        ));
  }
}

class TextController {
  Function setText = (text) {};
}
