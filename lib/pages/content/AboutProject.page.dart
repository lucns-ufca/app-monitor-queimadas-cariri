// @Developed by @lucns

import 'package:app_monitor_queimadas/pages/content/Dashboard.page.dart';
import 'package:app_monitor_queimadas/utils/Constants.dart';
import 'package:flutter/material.dart';

import 'package:app_monitor_queimadas/widgets/Toolbar.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  double toolbarHeight = 220;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final navigator = Navigator.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        body: Stack(
          children: [
            Container(
              height: toolbarHeight,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter,
                image: AssetImage("assets/images/soldadinho_araripe2.jpg"),
              )),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 28),
                MyToolbar(
                    title: "Sobre o Projeto",
                    onBackPressed: () async {
                      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
                    })
              ]),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height - toolbarHeight + Constants.DEFAULT_ROUND_BORDER,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: AppColors.fragmentBackground,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(Constants.DEFAULT_ROUND_BORDER), topLeft: Radius.circular(Constants.DEFAULT_ROUND_BORDER)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      spreadRadius: 4,
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      "...to be developed",
                      style: TextStyle(color: AppColors.textNormal, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
