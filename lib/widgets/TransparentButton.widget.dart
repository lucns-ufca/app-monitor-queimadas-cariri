import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

class TransparentButton extends StatelessWidget {
  final Function() onTap;
  final bool disabled;
  final String text;
  final double height = Constants.DEFAULT_WIDGET_HEIGHT;

  const TransparentButton({super.key, required this.onTap, required this.text, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: TextButton(
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(height))),
                backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                overlayColor: WidgetStateProperty.resolveWith((states) => disabled ? Colors.transparent : Colors.white.withOpacity(0.25))),
            onPressed: disabled ? null : () => onTap(),
            child: Text(text, style: TextStyle(fontSize: 18, color: disabled ? AppColors.buttonDisabled : AppColors.buttonNormal))));
  }
}
