// @Developed by @lucns

import 'package:monitor_queimadas_cariri/pages/content/MainScreen.page.dart';
import 'package:monitor_queimadas_cariri/utils/Constants.dart';
import 'package:flutter/material.dart';

import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  double toolbarHeight = 220;
  VideoPlayerController videoController = VideoPlayerController.asset('assets/videos/dark_bird.mp4');

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.initState();
    videoController.setLooping(true);
    videoController.initialize().then((_) => setState(() {}));
    videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    //final navigator = Navigator.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreenPage()));
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBackground,
        body: Stack(
          children: [
            AspectRatio(aspectRatio: videoController.value.aspectRatio, child: VideoPlayer(videoController)),
            SizedBox(
                height: toolbarHeight,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 32),
                      const Text("Soldadinho do Araripe", style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(width: 145, height: 0.5, color: Colors.white),
                      const SizedBox(height: 8),
                      const Text(
                        "Está em perigo\ncrítico de extinção",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )
                    ]))),
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
