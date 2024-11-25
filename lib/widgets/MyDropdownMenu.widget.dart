// @developed by @lucns

import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

class MyDropdownMenu extends StatefulWidget {
  final Widget buttonChild;
  final List<MyDropdownMenuItem> items;
  final void Function(bool expanded)? onExpanded;

  const MyDropdownMenu({
    required this.buttonChild,
    required this.items,
    this.onExpanded,
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
        height: expanded ? MediaQuery.of(context).size.height * 0.75 : 72,
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
                if (widget.onExpanded != null) widget.onExpanded!(expanded);
              },
              child: widget.buttonChild),
          Visibility(
              visible: expanded,
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.5),
              )),
          Expanded(
              child: SingleChildScrollView(
                  child: IntrinsicWidth(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(expanded ? widget.items.length : 0, (index) {
                            return Column(children: [
                              Visibility(
                                  visible: index > 0,
                                  child: Container(
                                    height: 1,
                                    color: AppColors.listDivider,
                                  )),
                              SizedBox(
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                                          overlayColor: WidgetStateProperty.all<Color>(AppColors.accent.withOpacity(0.75)),
                                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(64), side: const BorderSide(color: Colors.transparent)))),
                                      onPressed: () async {
                                        await Future.delayed(const Duration(milliseconds: 200));
                                        setState(() {
                                          expanded = !expanded;
                                        });
                                      },
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                                            Text(widget.items[index].title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                                            Text(widget.items[index].description, style: TextStyle(color: AppColors.accent.withOpacity(0.75), fontSize: 16))
                                          ]))))
                            ]);
                          })))))
        ]));
  }
}

class MyDropdownMenuItem {
  final String title, description;

  MyDropdownMenuItem(this.title, this.description);
}
