// @Developed by @lucns

import 'package:app_monitor_queimadas/pages/dialogs/PopupWindow.dart';
import 'package:flutter/material.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Utils.dart';

class PopupMenu extends PopupWindow {
  final BuildContext context;
  PopupMenu({required this.context}) : super(context: context, position: Utils.menuPosition(context), isCancelable: true);

  void showMenu(List<PopupMenuItem> items, Function(int index) onOptionSelected) {
    List<Widget> views = [];
    for (var i = 0; i < items.length; i++) {
      views.add(_getWidgetItem(items[i], () {
        dismiss();
        onOptionSelected(i);
      }));
    }
    showWindow(IntrinsicWidth(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: views)));
  }

  List<PopupMenuItem> generateIds(List<String> titles) {
    List<PopupMenuItem> list = <PopupMenuItem>[];
    for (var i = 0; i < titles.length; i++) {
      list.add(PopupMenuItem(text: titles[i], id: i));
    }
    return list;
  }

  Widget _getWidgetItem(PopupMenuItem item, Function() onClickListener) {
    return SizedBox(
        height: 48,
        child: TextButton(
            style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24)),
                overlayColor: WidgetStateProperty.all(AppColors.accent),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.transparent)))),
            onPressed: item.isEnabled
                ? () {
                    onClickListener();
                  }
                : null,
            child: Align(alignment: Alignment.centerLeft, child: Text(item.text, style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis, fontSize: 16, color: item.isEnabled ? AppColors.titleDark : Colors.white.withOpacity(0.5))))));
  }
}

class PopupMenuItem {
  final int id;
  final String text;
  bool isEnabled;

  PopupMenuItem({required this.text, required this.id, this.isEnabled = true});
}
