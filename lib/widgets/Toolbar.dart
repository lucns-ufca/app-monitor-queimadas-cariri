// @developed by @lucns

import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/material.dart';

class MyToolbar extends StatefulWidget {
  final String title;
  final Function() onBackPressed;
  final Function()? onMenuPressed;
  const MyToolbar({super.key, required this.title, required this.onBackPressed, this.onMenuPressed});

  @override
  State<StatefulWidget> createState() => MyToolbarState();
}

class MyToolbarState extends State<MyToolbar> {
  MyToolbarState();

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                generateButton(Icons.arrow_back_ios, widget.onBackPressed),
                Flexible(
                    child: Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                )),
                if (widget.onMenuPressed == null) const SizedBox(width: 56),
                if (widget.onMenuPressed != null) generateButton(Icons.more_vert, widget.onMenuPressed),
              ],
            )));
  }

  Widget generateButton(IconData icon, Function()? onClick) {
    if (onClick == null) {
      return const SizedBox(width: 56, height: 56, child: DecoratedBox(decoration: BoxDecoration(color: Colors.transparent)));
    }
    return SizedBox(
        width: 56,
        height: 56,
        child: ElevatedButton(
            onPressed: onClick,
            style: ButtonStyle(
                //foregroundColor: colorsStateText,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                elevation: MaterialStateProperty.all<double>(0.0),
                overlayColor: MaterialStateProperty.resolveWith((states) => AppColors.ripple),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(56)))),
            child: Center(child: Icon(icon, size: 24, color: Colors.white))));
  }
}
