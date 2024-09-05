// @Developed by @lucns

import 'package:app_monitor_queimadas/widgets/Button.dart';
import 'package:app_monitor_queimadas/widgets/TransparentButton.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/CustomText.dart';

class Dialogs {
  late BuildContext context;
  MyText? textTitle, textDescription;

  Dialogs(this.context);

  void showDialogWindow(Widget content, bool isCancelable) {
    showDialog(
        barrierDismissible: isCancelable,
        context: context,
        builder: (BuildContext context) {
          return PopScope(canPop: false, onPopInvoked: (didPop) => Future.value(false), child: CupertinoDialogAction(child: content));
        });
  }

  void showIndeterminateDialog(String title) {
    textTitle = MyText(text: title, maxLines: 10, style: const TextStyle(color: AppColors.textNormal), textAlign: TextAlign.start);
    showDialogWindow(
        PopScope(
            canPop: false,
            child: IntrinsicHeight(
                child: Container(
                    decoration: const BoxDecoration(color: AppColors.fragmentBackground, borderRadius: BorderRadius.all(Radius.circular(24))),
                    padding: const EdgeInsets.all(24),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                      const SizedBox(width: 36, child: CircularProgressIndicator(color: AppColors.textNormal)),
                      const SizedBox(width: 16),
                      Flexible(
                          child: textTitle ??
                              Text(
                                title,
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: const TextStyle(color: AppColors.textNormal),
                              ))
                    ])))),
        false);
  }

  void dismiss() {
    Navigator.pop(context);
  }

  void showDialogSuccess(Function onDismiss) {
    showDialogWindow(
        ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 330, maxWidth: 440, minHeight: 96, maxHeight: 440),
            child: Container(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
                decoration: const BoxDecoration(color: AppColors.fragmentBackground, borderRadius: BorderRadius.all(Radius.circular(24)), boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Enviado", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Obrigado por nos ajudar no monitoramento de queimadas.", textAlign: TextAlign.start, maxLines: 10, style: TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.visible)),
                  const SizedBox(
                    height: 24,
                  ),
                  Center(
                      child: SizedBox(
                          width: double.maxFinite,
                          child: TransparentButton(
                              text: "OK",
                              onTap: () async {
                                await Future.delayed(const Duration(milliseconds: 150));
                                Navigator.of(context).pop();
                                onDismiss();
                              })))
                ]))),
        false);
  }

  void showDialogError(String title, String description) {
    showDialogWindow(
        ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 330, maxWidth: 440, minHeight: 96, maxHeight: 440),
            child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.fragmentBackgroundError,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: AppColors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(textAlign: TextAlign.start, description, maxLines: 10, style: const TextStyle(color: Colors.white, fontSize: 16, overflow: TextOverflow.visible)),
                  const SizedBox(height: 24),
                  Center(
                      child: MyButton(
                          isNegative: true,
                          textButton: "OK",
                          onClick: () async {
                            await Future.delayed(const Duration(milliseconds: 150));
                            Navigator.of(context).pop();
                          }))
                ]))),
        false);
  }
}
