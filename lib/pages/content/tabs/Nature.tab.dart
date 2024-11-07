import 'package:flutter/material.dart';

class TabNaturePage extends StatefulWidget {
  const TabNaturePage({super.key});

  @override
  State<StatefulWidget> createState() => TabNaturePageState();
}

class TabNaturePageState extends State<TabNaturePage> with AutomaticKeepAliveClientMixin<TabNaturePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: const Color.fromARGB(255, 65, 48, 25),
      child: const Center(
          child: Text(
        "Em construção...",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 24),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
