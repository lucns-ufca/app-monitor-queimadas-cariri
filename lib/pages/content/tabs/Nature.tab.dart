import 'package:flutter/material.dart';

class TabNaturePage extends StatefulWidget {
  const TabNaturePage({super.key});

  @override
  State<StatefulWidget> createState() => TabNaturePageState();
}

class TabNaturePageState extends State<TabNaturePage> {
  @override
  Widget build(BuildContext context) {
    return Container(width: double.maxFinite, height: double.maxFinite, color: Colors.green);
  }
}
