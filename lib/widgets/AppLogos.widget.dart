import 'package:get_it/get_it.dart';
import 'package:monitor_queimadas_cariri/widgets/DynamicWidgetOpacity.widget.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppLogos extends StatelessWidget {
  final packageInfo = GetIt.I.get<PackageInfo>();
  final bool showAppLogo;
  AppLogos({this.showAppLogo = false, super.key});

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
                const SizedBox(width: 24),
                Expanded(child: Image.asset('assets/images/lisia.png')),
                SizedBox(width: showAppLogo ? 32 : 48),
                if (showAppLogo) Expanded(child: Image.asset('assets/images/monitor_queimadas_cariri.png')),
                if (showAppLogo) const SizedBox(width: 32),
                Expanded(child: Image.asset('assets/images/ufca_brightness.png')),
                const SizedBox(width: 24),
              ]))),
      const SizedBox(
        height: 16,
      ),
      Text("MONITOR DE QUEIMADAS VERSAO ${packageInfo.version}", style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: "MontBlancLight")),
      const SizedBox(
        height: 72,
      )
    ]);
  }
}
