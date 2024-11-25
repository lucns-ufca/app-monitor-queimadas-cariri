import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final CustomCheckBoxController? controller;
  final String? text;
  final bool checked;
  final bool lockManuallyCheck;
  final Function(bool)? onCheck;
  const CustomCheckBox({this.text, this.controller, this.checked = false, this.lockManuallyCheck = false, this.onCheck, super.key});

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 30,
            height: 30,
            child: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  side: const BorderSide(width: 2, color: AppColors.white_2),
                  shape: const CircleBorder(side: BorderSide(width: 2)),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return AppColors.buttonDisabled;
                    } else if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    } else if (states.contains(WidgetState.selected)) {
                      return AppColors.accent;
                    }
                    return Colors.transparent;
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
                ))),
        if (widget.text != null) const SizedBox(width: 4),
        Text(widget.text ?? "", style: const TextStyle(color: AppColors.white_2, fontSize: 18, fontWeight: FontWeight.bold))
      ],
    );
  }
}

class CustomCheckBoxController {
  void Function(bool) setChecked = (bool) {};
}
