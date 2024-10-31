import 'package:flutter/material.dart';

class TabNaturePage extends StatefulWidget {
  const TabNaturePage({super.key});

  @override
  State<StatefulWidget> createState() => TabNaturePageState();
}

class TabNaturePageState extends State<TabNaturePage> {
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
