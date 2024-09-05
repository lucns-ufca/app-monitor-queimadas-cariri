// @developed by @lucns

import 'package:app_monitor_queimadas/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/services.dart';

class MyFieldText extends StatefulWidget {
  final double? width, height;
  final int? maximumLines;
  final String? text;
  final String hintText;
  final TextInputAction action;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final bool isEnabled;
  final Function(String value)? onInput;

  const MyFieldText({super.key, this.width, this.height, this.maximumLines, this.text, required this.hintText, required this.action, required this.inputType, this.isEnabled = true, this.textCapitalization, this.inputFormatters, this.onInput});

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
    if (widget.text != null) {
      myController.text = widget.text!;
    }
    const double fontSize = 18;
    const double height = 36;
    return Focus(
        debugLabel: 'MyFieldText',
        child: Builder(builder: (BuildContext context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          return SizedBox(
              height: widget.height ?? height,
              width: widget.width ?? double.maxFinite,
              child: TextField(
                  onChanged: (text) {
                    if (widget.inputType == TextInputType.visiblePassword) {
                      setState(() {});
                    }
                    widget.onInput!(text);
                  },
                  maxLines: widget.maximumLines,
                  expands: true,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: widget.isEnabled,
                  inputFormatters: widget.inputFormatters,
                  controller: myController,
                  textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
                  textInputAction: widget.action,
                  keyboardType: widget.inputType,
                  obscureText: widget.inputType == TextInputType.visiblePassword && !showPassword,
                  cursorColor: AppColors.fieldTextCursor,
                  style: TextStyle(color: widget.isEnabled ? AppColors.fieldTextText : AppColors.textDisabled, fontSize: fontSize),
                  decoration: InputDecoration(
                      suffixIcon: widget.inputType == TextInputType.visiblePassword
                          ? Container(
                              width: 36,
                              height: 36,
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
                      contentPadding: const EdgeInsets.all(16))));
        }));
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
