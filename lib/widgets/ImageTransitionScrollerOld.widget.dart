// @developed by @lucns

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class ImageTransitionScroller2 extends StatefulWidget {
  final String assets;
  final double height;
  final double? width;

  const ImageTransitionScroller2({super.key, required this.assets, this.width, required this.height});

  @override
  State<ImageTransitionScroller2> createState() => _ImageTransitionScroller();
}

class _ImageTransitionScroller extends State<ImageTransitionScroller2> with TickerProviderStateMixin {
  Size? imageSize;
  double? imageWidth;
  Timer? timer;
  int duration = 10;

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  _ImageTransitionScroller();

  @override
  void initState() {
    super.initState();
    if (widget.width != null) imageSize = Size(widget.width!, widget.height);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      runAnimation();
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void runAnimation() {
    if (_scrollController.offset == 0) {
      _scrollController.animateTo(imageWidth! - MediaQuery.of(context).size.width, duration: Duration(seconds: duration), curve: Curves.easeInOut);
    } else {
      _scrollController.animateTo(0, duration: Duration(seconds: duration), curve: Curves.easeInOut);
    }
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(seconds: duration), () {
      runAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageSize == null) {
      Image image = Image.asset(widget.assets);
      Completer<ui.Image> completer = Completer<ui.Image>();
      image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        setState(() {
          imageSize = Size(info.image.width.toDouble(), info.image.height.toDouble());
        });
      }));
      return const SizedBox();
    }

    //double imageHeight = MediaQuery.of(context).size.height - widget.height;
    double imageHeight = widget.height;
    double scale = imageHeight / imageSize!.height;
    imageWidth = imageSize!.width * scale;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      controller: _scrollController, // your ScrollController
      child: Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.assets),
            fit: BoxFit.cover,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
      ),
    );
  }
}
