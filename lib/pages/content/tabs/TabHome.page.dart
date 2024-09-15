import 'dart:async';

import 'package:app_monitor_queimadas/models/user.model.dart';
import 'package:app_monitor_queimadas/pages/start/Login.page.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/ImageTransitionScroller.widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<StatefulWidget> createState() => TabHomePageState();
}

class TabHomePageState extends State<TabHomePage> {
  final user = GetIt.I.get<User>();
  bool runColor = false;
  bool loadingTop = true;
  bool loadingBottom = true;
  bool connected = true;
  List<String> listNews = [];
  List<String> listCities = [];
  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      Connectivity connectivity = Connectivity();
      List<ConnectivityResult> list = await connectivity.checkConnectivity();
      connected = list.any((item) => item != ConnectivityResult.none);
      setState(() {
        runColor = true;
      });
      subscription = connectivity.onConnectivityChanged.listen((list) {
        setState(() {
          connected = list.any((item) => item != ConnectivityResult.none);
        });
      });
    });
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedContainer(
          duration: const Duration(seconds: 10),
          width: double.maxFinite,
          height: 440,
          color: runColor ? AppColors.mainAreaBackground : AppColors.yellowSky,
          child: const Column(children: [SizedBox(height: 220), ImageTransitionScroller(duration: Duration(seconds: 10), assets: "assets/images/minimal_forest.png", width: 493, height: 220)])),
      Column(children: [
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Monitor", style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'MontBlancLight')), Text("de Queimadas Cariri", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              SizedBox(
                  width: 56,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (user.hasAccess()) {
                        // open profile page
                      } else {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      }
                    },
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
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: getMainContent())),
        const SizedBox(height: 72)
      ])
    ]);
  }

  Widget getMainContent() {
    if (loadingTop && listNews.isEmpty && loadingBottom && listCities.isEmpty) {
      if (connected) {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      )),
                  SizedBox(width: 16),
                  Text("Carregando dados...", style: TextStyle(color: Colors.white))
                ])));
      } else {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset("assets/icons/alert.svg", width: 16, height: 16), const SizedBox(width: 8), const Text("Sem conexão!", style: TextStyle(color: AppColors.red))])));
      }
    }
    if (listNews.isNotEmpty && listCities.isNotEmpty) {
      return Column(children: [_getTopContent(), const SizedBox(height: 16), _getBottomContent()]);
    } else if (listNews.isNotEmpty) {
      return Column(children: [_getTopContent(), const SizedBox(height: 16), Expanded(child: SizedBox(child: _getCenteredloading("Carregando cidades")))]);
    } else {
      // listCities.isNotEmpty
      return Column(children: [SizedBox(height: 220, child: _getCenteredloading("Carregando noticias...")), const SizedBox(height: 16), _getBottomContent()]);
    }
  }

  Widget _getTopContent() {
    return Container(
        padding: const EdgeInsets.all(16),
        width: double.maxFinite,
        height: 220,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (loadingTop)
            const Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 3,
                  )),
              SizedBox(width: 16),
              Text("Carregando noticias...", style: TextStyle(color: Colors.white))
            ]),
          const Text("conteudo aqui", style: TextStyle(color: Colors.white, fontSize: 24))
        ]));
  }

  Widget _getBottomContent() {
    return Expanded(
        child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (loadingBottom)
                const Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      )),
                  SizedBox(width: 16),
                  Text("Carregando cidades...", style: TextStyle(color: Colors.white))
                ]),
              const Text("lista aqui", style: TextStyle(color: Colors.white, fontSize: 24))
            ])));
  }

  Widget _getCenteredloading(String text) {
    return Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(36))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 3,
                  )),
              const SizedBox(width: 16),
              Text(text, style: const TextStyle(color: Colors.white))
            ])));
  }
}
