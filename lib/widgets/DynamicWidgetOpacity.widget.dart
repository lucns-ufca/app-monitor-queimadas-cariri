// @developed by @lucns

import 'dart:async';
import 'package:flutter/material.dart';

class DynamicWidgetOpacity extends StatefulWidget {
  final double opacityStart, opacityEnd;
  final Duration duration;
  final Widget child;

  DynamicWidgetOpacity(
      {Key? key,
      required this.duration,
      required this.opacityStart,
      required this.opacityEnd,
      required this.child})
      : super(key: key);

  @override
  State<DynamicWidgetOpacity> createState() => _DynamicWidgetOpacityState();
}

class _DynamicWidgetOpacityState extends State<DynamicWidgetOpacity> {
  _DynamicWidgetOpacityState();
  Timer? timer;
  bool imageOpacityGo = true;

  void _scheduleOpacity() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(widget.duration, () {
      setState(() {
        imageOpacityGo = !imageOpacityGo;
      });
      _scheduleOpacity();
    });
  }

  @override
  void initState() {
    super.initState();
    _scheduleOpacity();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: imageOpacityGo ? widget.opacityEnd : widget.opacityStart,
      duration: widget.duration,
      child: widget.child,
    );
  }
}
