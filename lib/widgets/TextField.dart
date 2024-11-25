// @developed by @lucns

import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:monitor_queimadas_cariri/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/services.dart';

class MyFieldText extends StatefulWidget {
  final double? width, height;
  final int? maximumLines;
  final String? text;
  final String hintText;
  final TextInputAction action;
  final TextInputType inputType;
  final TextAlignVertical? textAlignVertical;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final bool isEnabled;
  final Color textColor;
  final int? maximumLength;
  final Function(String value)? onInput;

  const MyFieldText(
      {super.key,
      this.width,
      this.height,
      this.textColor = Colors.white,
      this.textAlignVertical,
      this.maximumLines,
      this.text,
      required this.hintText,
      required this.action,
      required this.inputType,
      this.isEnabled = true,
      this.textCapitalization,
      this.inputFormatters,
      this.maximumLength,
      this.onInput});

  @override
  State<MyFieldText> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyFieldText> {
  final TextEditingController myController = TextEditingController();

  bool showPassword = false;

  _MyTextFieldState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text != null && widget.text!.isNotEmpty) {
      myController.text = widget.text!;
    }
    const double fontSize = 18;
    const double height = Constants.DEFAULT_WIDGET_HEIGHT;
    return SizedBox(
        height: widget.height ?? height,
        width: widget.width ?? MediaQuery.of(context).size.width,
        child: Focus(
            debugLabel: 'MyFieldText',
            child: Builder(builder: (BuildContext context) {
              final FocusNode focusNode = Focus.of(context);
              final bool hasFocus = focusNode.hasFocus;
              return TextField(
                  onChanged: (text) {
                    if (widget.inputType == TextInputType.visiblePassword) {
                      setState(() {});
                    }
                    if (widget.onInput != null) widget.onInput!(text);
                  },
                  maxLength: widget.maximumLength,
                  maxLines: widget.inputType == TextInputType.multiline ? null : 1,
                  expands: widget.inputType == TextInputType.multiline,
                  textAlign: TextAlign.start,
                  textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.center,
                  enabled: widget.isEnabled,
                  inputFormatters: widget.inputFormatters,
                  controller: myController,
                  textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
                  textInputAction: widget.action,
                  keyboardType: widget.inputType,
                  obscureText: widget.inputType == TextInputType.visiblePassword && !showPassword,
                  cursorColor: AppColors.fieldTextCursor,
                  style: TextStyle(color: widget.isEnabled ? widget.textColor : widget.textColor.withOpacity(0.5), fontSize: fontSize),
                  decoration: InputDecoration(
                      suffixIcon: widget.inputType == TextInputType.visiblePassword
                          ? Container(
                              width: height,
                              height: height,
                              padding: const EdgeInsets.only(right: 8),
                              child: myController.text.isEmpty
                                  ? const SizedBox()
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: AppColors.accent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      ),
                                      onPressed: () {
                                        Utils.vibrate();
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                      child: Icon(
                                        showPassword ? Icons.visibility_off : Icons.visibility,
                                        size: 16,
                                        color: widget.isEnabled ? AppColors.white : AppColors.fieldTextHint,
                                      )),
                            )
                          : null,
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(height)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(height)),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(height)),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: widget.isEnabled ? (hasFocus ? AppColors.fieldTextFocusedBackground : AppColors.fieldTextBackground) : AppColors.fieldTextDisabledBackground,
                      filled: true,
                      hintStyle: TextStyle(color: widget.isEnabled ? AppColors.fieldTextHint : AppColors.textDisabled, fontSize: fontSize, fontWeight: FontWeight.w400),
                      hintText: widget.hintText,
                      contentPadding: EdgeInsets.only(left: 16, right: 16, top: widget.inputType == TextInputType.multiline ? 16 : 0)));
            })));
  }
}

class CpfFormatter extends TextInputFormatter {
  bool isUpdating = false;
  String old = "";
  final String DEFAULT_MASK = "###.###.###-##";

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 14) return newValue;
    if (newValue.text.length == 15) return oldValue;
    String str = unmask(newValue.text);
    String mascara = "";
    if (isUpdating) {
      old = str;
      isUpdating = false;
      return newValue;
    }
    int i = 0;
    for (int a = 0; a < DEFAULT_MASK.length; a++) {
      if ((DEFAULT_MASK[a] != '#' && str.length > old.length) || (DEFAULT_MASK[a] != '#' && str.length < old.length && str.length != i)) {
        mascara += DEFAULT_MASK[a];
        continue;
      }
      try {
        mascara += str[i];
      } catch (e) {
        break;
      }
      i++;
    }
    isUpdating = true;
    return TextEditingValue(text: mascara, selection: TextSelection.collapsed(offset: mascara.length));
  }

  String unmask(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
