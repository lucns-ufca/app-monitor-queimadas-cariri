// Developed by @lucns

import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_monitor_queimadas/pages/start/First.page.dart';
import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:app_monitor_queimadas/utils/Log.out.dart';
import 'package:app_monitor_queimadas/widgets/MeasureSize.widget.dart';
import 'package:flutter/material.dart';

class LoginPageTest extends StatefulWidget {
  const LoginPageTest({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPageTest> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !loading,
        onPopInvoked: (didPop) async {
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FirstPage()));
        },
        child: Scaffold(resizeToAvoidBottomInset: false, body: Container(color: AppColors.appBackground, child: const ImageTransitionScroller2(assets: "assets/images/montains.jpg"))));
  }
}

class ImageTransitionScroller2 extends StatefulWidget {
  final double width, height;
  final String assets;
  const ImageTransitionScroller2({required this.assets, this.width = 0, this.height = 0, super.key});

  @override
  State<StatefulWidget> createState() => ImageTransitionScrollerState();
}

class ImageTransitionScrollerState extends State<ImageTransitionScroller2> {
  Size? sizeSpace, sizeImage, sizeImageFitted;

  @override
  void initState() {
    Log.d("lucas", "initState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Log.d("lucas", "build");
    return MeasureSize(
      onChange: (s) {
        sizeSpace = s;
        Log.d("lucas", "sizeSpace ${sizeSpace!.width}x${sizeSpace!.height}");
        Image image = Image.asset(widget.assets);
        Completer<ui.Image> completer = Completer<ui.Image>();
        image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          sizeImage = Size(info.image.width.toDouble(), info.image.height.toDouble());
          Log.d("lucas", "sizeImage ${sizeImage!.width}x${sizeImage!.height}");
          //double imageHeight = MediaQuery.of(context).size.height - widget.height;
          double imageHeight = sizeSpace!.height;
          double scale = imageHeight / sizeImage!.height;
          double imageWidth = sizeImage!.width * scale;
          Log.d("lucas", "sizeImageFitted $imageWidth x $imageHeight");
          setState(() {
            sizeImageFitted = Size(imageWidth, imageHeight);
          });
        }));
      },
      child: Container(width: double.maxFinite, height: double.maxFinite, color: AppColors.appBackground, child: selectContent()),
    );
  }

  Widget selectContent() {
    if (sizeSpace == null || sizeImageFitted == null) return const SizedBox();
    return Stack(
        children: [SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: sizeImageFitted!.width, height: sizeImageFitted!.height, child: Image.asset(widget.assets, width: sizeImageFitted!.width, height: sizeImageFitted!.height)))]);
  }
}
