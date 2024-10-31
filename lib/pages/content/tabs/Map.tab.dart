import 'package:flutter/material.dart';

class TabMapPage extends StatefulWidget {
  const TabMapPage({super.key});

  @override
  State<StatefulWidget> createState() => TabMapPageState();
}

class TabMapPageState extends State<TabMapPage> {
  @override
  Widget build(BuildContext context) {
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
}
