import 'dart:async';
import 'dart:ui' as ui;

import 'package:monitor_queimadas_cariri/widgets/MeasureSize.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ImageTransitionScroller extends StatefulWidget {
  final double width, height;
  final String assets;
  final Color? color;
  final bool repeat;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  const ImageTransitionScroller({this.duration = const Duration(seconds: 10), this.padding = EdgeInsets.zero, this.child = const SizedBox(), this.repeat = true, this.color, required this.assets, this.width = 0, this.height = 0, super.key});

  @override
  State<StatefulWidget> createState() => ImageTransitionScrollerState();
}

class ImageTransitionScrollerState extends State<ImageTransitionScroller> with TickerProviderStateMixin {
  Size? sizeSpace, sizeImage, sizeImageFitted;
  Timer? timer;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    if (widget.width > 0 && widget.height > 0) sizeSpace = Size(widget.width, widget.height);
    super.initState();
    Image image = Image.asset(widget.assets);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
      sizeImage = Size(info.image.width.toDouble(), info.image.height.toDouble());
      double imageHeight = sizeSpace!.height;
      double scale = imageHeight / sizeImage!.height;
      double imageWidth = sizeImage!.width * scale;
      if (mounted) {
        setState(() {
          sizeImageFitted = Size(imageWidth, imageHeight);
        });
      }
    }));
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      runAnimation();
    });
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  void runAnimation() {
    if (!scrollController.hasClients) return;
    if (scrollController.offset == 0) {
      scrollController.animateTo(sizeImageFitted!.width - MediaQuery.of(context).size.width, duration: widget.duration, curve: Curves.easeInOut);
    } else {
      scrollController.animateTo(0, duration: widget.duration, curve: Curves.easeInOut);
    }
    if (timer != null) timer!.cancel();
    if (widget.repeat) {
      timer = Timer(widget.duration, () {
        runAnimation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sizeSpace == null) {
      return MeasureSize(
          onChange: (s) {
            sizeSpace = s;
          },
          child: Container(width: double.maxFinite, height: double.maxFinite, color: widget.color ?? Colors.transparent));
    }
    if (sizeImage == null) {
      return Container(width: MediaQuery.of(context).size.width, height: sizeSpace!.height, color: widget.color ?? Colors.transparent);
    }
    return Container(width: MediaQuery.of(context).size.width, height: sizeSpace!.height, color: widget.color ?? Colors.transparent, child: selectContent());
  }

  Widget selectContent() {
    if (sizeSpace == null || sizeImageFitted == null) return const SizedBox();
    return Stack(children: [
      SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: sizeImageFitted!.width, height: sizeImageFitted!.height, child: Image.asset(widget.assets, width: sizeImageFitted!.width, height: sizeImageFitted!.height))),
      widget.child
    ]);
  }
}
