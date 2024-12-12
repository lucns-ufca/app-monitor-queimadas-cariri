// @Developed by @lucns

import 'package:monitor_queimadas_cariri/widgets/TransparentButton.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/CustomText.dart';

class Dialogs {
  late BuildContext context;
  MyText? textTitle, textDescription;
  final Color backgroundColor, accentColor;

  Dialogs(this.context, {this.backgroundColor = AppColors.fragmentBackground, this.accentColor = AppColors.accent});

  Future<void> showDialogWindow(Widget content, bool isCancelable) {
    return showDialog(
        barrierDismissible: isCancelable,
        context: context,
        builder: (BuildContext context) {
          return PopScope(canPop: false, onPopInvokedWithResult: (bool didPop, Object? result) => Future.value(false), child: CupertinoDialogAction(child: content));
        });
  }

  Future<void> showIndeterminateDialog(String title) {
    return showDialogWindow(
        PopScope(
            canPop: false,
            child: IntrinsicHeight(
                child: Container(
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        spreadRadius: 4,
                        blurRadius: 4,
                        offset: Offset(0, 10),
                      )
                    ], color: backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(24))),
                    padding: const EdgeInsets.all(24),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                      SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: accentColor)),
                      const SizedBox(width: 16),
                      Flexible(
                          child: Text(
                        title,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: AppColors.textNormal, fontSize: 20, fontWeight: FontWeight.w500),
                      ))
                    ])))),
        false);
  }

  void dismiss() {
    Navigator.pop(context);
  }

  Future<void> showDialogSuccess(String title, String description, {Function? onDismiss}) {
    return showDialogWindow(
        Container(
            width: 360,
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(24)), boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Flexible(child: Text(title, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.start, maxLines: 10, style: const TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.visible)),
              const SizedBox(
                height: 24,
              ),
              Center(
                  child: SizedBox(
                      width: double.maxFinite,
                      child: TransparentButton(
                          textColor: accentColor,
                          text: "OK",
                          onTap: () async {
                            await Future.delayed(const Duration(milliseconds: 150));
                            Navigator.of(context).pop();
                            if (onDismiss != null) onDismiss();
                          })))
            ])),
        false);
  }

  Future<void> showDialogInfo(String title, String description, {String? positiveText, Function? onPositiveClick, String? negativeText, Function? onNegativeClick}) {
    return showDialogWindow(
        Container(
            width: 360,
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(24)), boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ]),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Flexible(
                  child: Text(
                title,
                maxLines: 4,
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, overflow: TextOverflow.visible),
              )),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.justify, maxLines: 10, style: const TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.visible)),
              const SizedBox(height: 24),
              // INSERIR DOIS BOTOES AQUI
              if ((positiveText != null || onPositiveClick != null) && onNegativeClick == null)
                Center(
                    child: SizedBox(
                        width: double.maxFinite,
                        child: TransparentButton(
                            textColor: accentColor,
                            text: positiveText ?? "OK",
                            onTap: () async {
                              await Future.delayed(const Duration(milliseconds: 250));
                              if (onPositiveClick != null) onPositiveClick();
                              dismiss();
                            })))
            ])),
        false);
  }

  void showDialogError(String title, String description) {
    showDialogWindow(
        Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: AppColors.red, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(textAlign: TextAlign.start, description, maxLines: 10, style: const TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.visible)),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.maxFinite,
                  child: TransparentButton(
                      textColor: accentColor,
                      text: "OK",
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        dismiss();
                      }))
            ])),
        false);
  }

  void showBlackLoading({String text = ""}) {
    showDialogWindow(
        PopScope(
            canPop: false,
            child: IntrinsicHeight(
                child: Container(
                    decoration: const BoxDecoration(color: AppColors.shadow, borderRadius: BorderRadius.all(Radius.circular(24))),
                    padding: const EdgeInsets.all(24),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                      SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: accentColor)),
                      if (text.isNotEmpty) const SizedBox(width: 16),
                      if (text.isNotEmpty)
                        Flexible(
                            child: Text(
                          text,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: AppColors.textNormal, fontSize: 20, fontWeight: FontWeight.w500),
                        ))
                    ])))),
        false);
  }
}
