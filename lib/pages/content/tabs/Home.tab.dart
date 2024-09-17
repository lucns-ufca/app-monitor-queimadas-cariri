import 'dart:async';
import 'dart:io';

import 'package:app_monitor_queimadas/models/User.model.dart';
import 'package:app_monitor_queimadas/pages/content/AboutProject.page.dart';
import 'package:app_monitor_queimadas/pages/dialogs/PopupMenu.dart';
import 'package:app_monitor_queimadas/pages/start/Acess.page.dart';
import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/repositories/App.repository.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/widgets/ContainerGradient.widget.dart';
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
  final appRepository = GetIt.I.get<AppRepository>();
  bool runColor = false;
  bool loadingTop = true;
  bool loadingBottom = true;
  bool connected = true;
  List<String> listNews = [];
  List<String> listCities = [];
  StreamSubscription<List<ConnectivityResult>>? subscription;
  Future<File?>? imageProfile;

  void profileClick() async {
    if (user.hasAccess()) {
      showMenuWindow();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessPage()));
    }
  }

  void showMenuWindow() {
    PopupMenu popupMenu = PopupMenu(context: context);
    List<String> titles = [if (!user.hasAccess()) "Login", if (user.hasAccess()) "Validação de queimadas", "Sobre o Projeto", if (user.hasAccess()) "Logout"];
    var items = popupMenu.generateIds(titles);
    popupMenu.showMenu(items, (index) async {
      switch (items[index].text) {
        case "Login":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccessPage()));
          break;
        case "Sobre o Projeto":
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AboutPage()));
        case "Logout":
          user.clear();
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          break;
      }
    });
  }

  @override
  void initState() {
    imageProfile = user.getProfileImage();
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
    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ContainerGradient(
          colors: AppColors.gradientSky,
          duration: const Duration(seconds: 30),
          child: Column(children: [const SizedBox(height: 220), const ImageTransitionScroller(duration: Duration(seconds: 10), assets: "assets/images/minimal_forest.png", width: 493, height: 220), Expanded(child: Container(color: AppColors.appBackground))])),
      Column(children: [
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Monitor", style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'MontBlancLight')), Text("de Queimadas Cariri", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              FutureBuilder(
                  future: imageProfile,
                  builder: (context, result) {
                    if (result.connectionState == ConnectionState.done) {
                      if (result.data == null) {
                        return getProfileButton();
                      }
                      return SizedBox(
                          width: 56,
                          height: 56,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(38),
                              child: Stack(children: [
                                Image(image: FileImage(result.data as File), width: 56, height: 56),
                                Positioned.fill(
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.white.withOpacity(0.5),
                                          onTap: () => profileClick(),
                                        )))
                              ])));
                    }
                    return getProfileButton(loading: true);
                  }),
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

  Widget getProfileButton({bool loading = false}) {
    return SizedBox(
        width: 56,
        height: 56,
        child: ElevatedButton(
          onPressed: () => profileClick(),
          style: ButtonStyle(
              //foregroundColor: colorsStateText,
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsetsDirectional.zero),
              elevation: WidgetStateProperty.all<double>(0.0),
              overlayColor: WidgetStateProperty.resolveWith((states) => AppColors.accent),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
              shape: WidgetStateProperty.all<OvalBorder>(const OvalBorder())),
          child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)) : const Icon(Icons.person_outline),
        ));
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
