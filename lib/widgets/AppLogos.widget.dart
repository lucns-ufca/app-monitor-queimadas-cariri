import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/widgets/DynamicWidgetOpacity.widget.dart';
import 'package:flutter/material.dart';

class AppLogos extends StatelessWidget {
  const AppLogos({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      DynamicOpacity(
          opacityStart: 1,
          opacityEnd: 0.5,
          duration: const Duration(milliseconds: 2500),
          child: SizedBox(
              height: 56,
              child: Row(children: [
                Expanded(child: Image.asset('assets/images/lisia.png')),
                const SizedBox(width: 48),
                Expanded(child: Image.asset('assets/images/ufca_brightness.png')),
              ]))),
      const SizedBox(
        height: 16,
      ),
      const Text("MONITOR DE QUEIMADAS VERSAO ${Constants.APP_VERSION}", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "MontBlancLight")),
      const SizedBox(
        height: 32,
      )
    ]);
  }
}
