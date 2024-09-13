// Developed by @lucns

import 'package:app_monitor_queimadas/pages/content/MainScreen.page.dart';
import 'package:app_monitor_queimadas/pages/start/Login.page.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:app_monitor_queimadas/widgets/DynamicWidgetOpacity.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    animation = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut)).animate(animationController!);
    animationController!.forward();

    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.fitHeight,
          alignment: FractionalOffset.topCenter,
          image: AssetImage("assets/images/chapada_car_montain.jpg"),
        )),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.only(top: 48, right: 24),
                width: double.maxFinite,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          },
                          style: ButtonStyle(
                              //foregroundColor: colorsStateText,
                              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                              elevation: WidgetStateProperty.all<double>(0.0),
                              overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent),
                              backgroundColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
                              shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
                          child: const Icon(Icons.person_outline),
                        )))),
            Expanded(
                child: AnimatedBuilder(
                    animation: animationController!,
                    builder: (context, child) {
                      return Transform.translate(
                          offset: Offset((1.0 - animation!.value) * 100, 0),
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 36),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 56,
                                  ),
                                  Image.asset("assets/icons/initial_white_marker.png", width: 52, height: 72),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  const Text("CHAPADA", style: TextStyle(color: Colors.white, fontSize: 72, height: 1, fontFamily: 'CocoSharpBold')),
                                  const Text("DO ARARIPE", style: TextStyle(color: Colors.white, fontSize: 48, height: 1, fontFamily: 'MontBlancLight')),
                                ],
                              )));
                    })),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                      AnimatedBuilder(
                          animation: animationController!,
                          builder: (context, child) {
                            return Transform.translate(
                                offset: Offset((1.0 - animation!.value) * (-100), 0),
                                child: Opacity(
                                    opacity: animation!.value,
                                    child: Container(
                                        height: 85,
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [
                                            0.0,
                                            1.0
                                          ], colors: [
                                            Color.fromARGB(127, 58, 58, 58),
                                            Color.fromARGB(148, 72, 228, 255),
                                          ]),
                                          borderRadius: BorderRadius.circular(48),
                                        ),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 8,
                                              padding: EdgeInsets.zero,
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.black,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Padding(padding: EdgeInsets.only(left: 36), child: Text("Acessar plataforma.\nSou visitante.", style: TextStyle(color: Colors.white, fontSize: 20, height: 1.5, fontWeight: FontWeight.w600))),
                                                SizedBox(
                                                  height: double.maxFinite,
                                                  width: 96,
                                                  //decoration: const BoxDecoration(color: Color.fromARGB(87, 40, 248, 255), borderRadius: BorderRadius.only(topRight: Radius.circular(48), bottomRight: Radius.circular(48))),
                                                  child: Center(child: Image.asset("assets/icons/arrow_right.png", width: 36, height: 36)),
                                                )
                                              ],
                                            ),
                                            onPressed: () async {
                                              await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreenPage()));
                                            }))));
                          }),
                      const SizedBox(
                        height: 64,
                      ),
                      DynamicWidgetOpacity(opacityStart: 1, opacityEnd: 0.5, duration: const Duration(milliseconds: 2500), child: const Image(image: ResizeImage(AssetImage('assets/images/ufca_white.png'), width: 105, height: 33))),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text("MONITOR DE QUEIMADAS VERSAO ${Constants.APP_VERSION}", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "MontBlancLight")),
                      const SizedBox(
                        height: 32,
                      ),
                    ]))),
          ],
        ),
      ),
    );
  }
}
