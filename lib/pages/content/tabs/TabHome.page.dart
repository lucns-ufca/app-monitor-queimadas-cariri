import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/ImageTransitionScroller.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<StatefulWidget> createState() => TabHomePageState();
}

class TabHomePageState extends State<TabHomePage> {
  bool runColor = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        runColor = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedContainer(
          duration: const Duration(seconds: 10),
          width: double.maxFinite,
          height: 440,
          color: runColor ? AppColors.mainAreaBackground : AppColors.yellowSky,
          child: const Column(children: [SizedBox(height: 220), ImageTransitionScroller(assets: "assets/images/minimal_forest.png", width: 493, height: 220)])),
      Column(children: [
        const SizedBox(height: 20),
        Container(
            padding: const EdgeInsets.all(24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Monitor", style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'MontBlancLight')), Text("de Queimadas do Cariri", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              SizedBox(
                  width: 56,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        //foregroundColor: colorsStateText,
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                        elevation: WidgetStateProperty.all<double>(0.0),
                        overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent),
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
                        shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
                    child: const Icon(Icons.person_outline),
                  ))
            ])),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  const SizedBox(height: 110),
                  Container(
                      width: double.maxFinite,
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      //decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(36))),
                      child: Center(
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(36))),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.accent,
                                      strokeWidth: 3,
                                    )),
                                SizedBox(width: 16),
                                Text("Carregando notícias...", style: TextStyle(color: Colors.white))
                              ])))),
                  const SizedBox(height: 16),
                  Expanded(
                      child: Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(16),
                          child: Center(
                              child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(36))),
                                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                    SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppColors.accent,
                                          strokeWidth: 3,
                                        )),
                                    SizedBox(width: 8),
                                    Text("Carregando cidades...", style: TextStyle(color: Colors.white))
                                  ])))))
                ]))),
        const SizedBox(height: 72)
      ])
    ]);
  }
}
