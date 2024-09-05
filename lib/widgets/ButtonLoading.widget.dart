import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/MeasureSize.widget.dart';
import 'package:flutter/material.dart';

class ButtonLoading extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final Function()? onPressed;
  final ButtonLoadingController? controller;
  const ButtonLoading({super.key, this.text, this.icon, this.controller, required this.onPressed});

  @override
  State<StatefulWidget> createState() => ButtonLoadingState();
}

class ButtonLoadingState extends State<ButtonLoading> {
  double width = 0;
  double maximum = 0;
  double minimum = 48;

  @override
  void initState() {
    if (widget.controller != null) widget.controller!.setLoading = setLoading;
    super.initState();
  }

  void setLoading(bool state) {
    setState(() {
      if (state) {
        width = minimum;
      } else {
        width = maximum;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (maximum == 0) {
      return MeasureSize(
          onChange: (size) {
            setState(() {
              maximum = size.width;
              width = maximum;
            });
          },
          child: SizedBox(height: minimum, width: double.maxFinite));
    }
    return AnimatedContainer(
        height: minimum,
        width: width,
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: () async {
            if (width == minimum || widget.onPressed == null) return;
            widget.onPressed!();
            /*
            setState(() {
              width = minimum;
            });
            */
          },
          style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              splashFactory: width == 56 ? NoSplash.splashFactory : InkRipple.splashFactory,
              backgroundColor: WidgetStateProperty.all(widget.onPressed == null ? AppColors.buttonDisabled : AppColors.buttonNormal),
              foregroundColor: WidgetStateProperty.all(widget.onPressed == null ? AppColors.textDisabled : Colors.white),
              overlayColor: WidgetStateProperty.all(width == minimum || widget.onPressed == null ? Colors.transparent : Colors.white.withOpacity(0.3))),
          child: AnimatedSwitcher(
              switchInCurve: Curves.linear,
              switchOutCurve: Curves.linear,
              duration: const Duration(milliseconds: 100),
              child: width == minimum
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.text != null)
                          Flexible(
                              child: Text(
                            widget.text!,
                            style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 20, fontWeight: FontWeight.w700),
                          )),
                        const SizedBox(width: 8),
                        if (widget.icon != null) widget.icon!
                      ],
                    )),
        ));
  }
}

class ButtonLoadingController {
  Function(bool) setLoading = (a) {};
}
