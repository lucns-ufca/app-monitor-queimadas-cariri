import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final CustomCheckBoxController? controller;
  final bool checked;
  final bool lockManuallyCheck;
  final Function(bool)? onCheck;
  const CustomCheckBox({this.controller, this.checked = false, this.lockManuallyCheck = false, this.onCheck, super.key});

  @override
  State<StatefulWidget> createState() => CustomCheckBoxState();
}

class CustomCheckBoxState extends State<CustomCheckBox> {
  bool? checked;

  @override
  void initState() {
    if (widget.controller != null) widget.controller!.setChecked = setChecked;
    super.initState();
  }

  void setChecked(bool checked) {
    setState(() {
      this.checked = checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 30,
        height: 30,
        child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              side: const BorderSide(width: 2, color: AppColors.textDisabled),
              shape: const CircleBorder(side: BorderSide(width: 2)),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.buttonDisabled;
                } else if (states.contains(WidgetState.pressed)) {
                  return Colors.white;
                } else if (states.contains(WidgetState.selected)) {
                  return AppColors.accent;
                }
                return AppColors.appBackground;
              }),
              checkColor: AppColors.appBackground,
              value: checked ?? widget.checked,
              onChanged: (isChecked) {
                if (widget.onCheck != null) widget.onCheck!(isChecked ?? false);
                if (widget.lockManuallyCheck) return;
                setState(() {
                  checked = !(checked ?? widget.checked);
                });
              },
            )));
  }
}

class CustomCheckBoxController {
  void Function(bool) setChecked = (bool) {};
}
