// @developed by @lucns

import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:flutter/material.dart';

class MyDropdownMenu extends StatefulWidget {
  final Widget buttonChild;
  final List<MyDropdownMenuItem> items;

  const MyDropdownMenu({
    required this.buttonChild,
    required this.items,
    super.key,
  });

  @override
  State<MyDropdownMenu> createState() => MyDropdownMenuState();
}

class MyDropdownMenuState extends State<MyDropdownMenu> {
  double height = Constants.DEFAULT_WIDGET_HEIGHT;
  bool expanded = false;

  MyDropdownMenuState();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        curve: Curves.ease,
        height: expanded ? MediaQuery.of(context).size.height * 0.75 : 64,
        //color: AppColors.fragmentBackground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: AppColors.fragmentBackground,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                  overlayColor: WidgetStateProperty.all<Color>(AppColors.accent.withOpacity(0.75)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(64), side: const BorderSide(color: Colors.transparent)))),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: widget.buttonChild),
          Expanded(
              child: IntrinsicWidth(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        expanded ? widget.items.length : 0,
                        (index) => SizedBox(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                                    overlayColor: WidgetStateProperty.all<Color>(AppColors.accent.withOpacity(0.75)),
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(64), side: const BorderSide(color: Colors.transparent)))),
                                onPressed: () {
                                  setState(() {
                                    expanded = !expanded;
                                  });
                                },
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [Text(widget.items[index].title, style: const TextStyle(color: Colors.white, fontSize: 18)), Text(widget.items[index].description, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 16))])))),
                      ))))
        ]));
  }
}

class MyDropdownMenuItem {
  final String title, description;

  MyDropdownMenuItem(this.title, this.description);
}
