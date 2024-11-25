import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final Axis direction;
  final List<RadioButton> radios;
  final Color colorNormal, colorChecked, colorDisabled;
  final Function(RadioButton) onCheckChanged;

  const RadioGroup({required this.onCheckChanged, required this.radios, this.colorChecked = AppColors.accent, this.colorNormal = AppColors.white_2, this.colorDisabled = AppColors.white_3, this.direction = Axis.vertical, super.key});

  @override
  State<StatefulWidget> createState() => RadioGroupState();
}

class RadioGroupState extends State<RadioGroup> {
  int selected = 0;

  @override
  void initState() {
    for (int i = 0; i < widget.radios.length; i++) {
      if (widget.radios[i].checked) selected = i;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == Axis.vertical) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.radios.length, (index) {
            if (index < widget.radios.length) {
              return Column(
                children: [getWidget(index), const SizedBox(height: 8)],
              );
            }
            return getWidget(index);
          }));
    }
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.radios.length, (index) {
          if (index < widget.radios.length) {
            return Row(
              children: [getWidget(index), const SizedBox(width: 16)],
            );
          }
          return getWidget(index);
        }));
  }

  Widget getWidget(int index) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Transform.scale(
          scale: 1.25,
          child: SizedBox(
              width: 24,
              height: 24,
              child: Radio(
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      if (states.contains(WidgetState.disabled)) {
                        return widget.colorChecked.withOpacity(0.5);
                      }
                      return widget.colorChecked;
                    }
                    if (states.contains(WidgetState.disabled)) {
                      return widget.colorNormal.withOpacity(0.5);
                    }
                    return widget.colorNormal;
                  }),
                  value: index,
                  groupValue: selected,
                  onChanged: (value) {
                    widget.radios[selected].checked = false;
                    widget.radios[index].checked = true;
                    widget.onCheckChanged(widget.radios[index]);
                    setState(() {
                      selected = value!;
                    });
                  }))),
      const SizedBox(
        width: 8,
      ),
      Text(
        widget.radios[index].title,
        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
      )
    ]);
  }
}

class RadioButton {
  String title;
  bool checked, enabled;

  RadioButton({required this.title, required this.checked, required this.enabled});
}
