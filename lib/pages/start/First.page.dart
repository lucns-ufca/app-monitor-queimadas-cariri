// Developed by @lucns

import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/pages/start/Acess.page.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/utils/Notification.provider.dart';
import 'package:monitor_queimadas_cariri/widgets/AppLogos.widget.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;

  void clearNotifications() async {
    NotificationProvider notificationProvider = await NotificationProvider.getInstance();
    notificationProvider.removeAll();
  }

  @override
  void initState() {
    clearNotifications();
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
    return FocusDetector(
        onVisibilityGained: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black.withOpacity(0.002),
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ));
        },
        child: Scaffold(
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
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Image.asset('assets/images/monitor_queimadas_cariri.png', width: 184, height: 72),
                      SizedBox(
                          width: 56,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Future.delayed(const Duration(milliseconds: 300));
                              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccessPage()));
                              //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessPage()));
                            },
                            style: ButtonStyle(
                                //foregroundColor: colorsStateText,
                                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
                                elevation: WidgetStateProperty.all<double>(0.0),
                                overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent),
                                backgroundColor: WidgetStateProperty.all<Color>(AppColors.ticketColor),
                                shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
                            child: const Icon(Icons.person_outline),
                          ))
                    ])),
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
                                      Image.asset("assets/icons/initial_white_marker.png", height: 56),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      const Text("CHAPADA", style: TextStyle(color: Colors.white, fontSize: 56, height: 1, fontFamily: 'CocoSharpBold')),
                                      const Text("DO ARARIPE", style: TextStyle(color: Colors.white, fontSize: 36, height: 1, fontFamily: 'MontBlancLight')),
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
                                                style: ButtonStyle(
                                                  overlayColor: WidgetStatePropertyAll(AppColors.accent.withOpacity(0.5)),
                                                  elevation: const WidgetStatePropertyAll(8),
                                                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24)),
                                                  backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                                                  shadowColor: const WidgetStatePropertyAll(Colors.black),
                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(48))),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Acessar plataforma.\nSou visitante.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
                                                    const SizedBox(width: 16),
                                                    Image.asset("assets/icons/arrow_right.png", width: 36, height: 36),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreenPage()));
                                                  //await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreenPage()));
                                                }))));
                              }),
                          const SizedBox(
                            height: 64,
                          ),
                          AppLogos()
                        ]))),
              ],
            ),
          ),
        ));
  }
}
