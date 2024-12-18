import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:monitor_queimadas_cariri/widgets/MeasureSize.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'dart:math' as math;

class GaugeChart extends StatefulWidget {
  final double progress;
  final ProgressController? progressController;
  final double? size;
  final Widget child;
  const GaugeChart({super.key, required this.child, this.size, this.progress = 0, this.progressController});

  @override
  GaugeChartState createState() => GaugeChartState();
}

class GaugeChartState extends State<GaugeChart> with TickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? controller;
  Tween<double>? tween;
  Size? size;

  @override
  void initState() {
    if (widget.size != null) size = Size(widget.size!, widget.size!);
    if (widget.progressController != null) widget.progressController!.setProgress = setProgress;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    controller!.addListener(() {
      setState(() {});
    });
    tween = Tween(begin: 0, end: widget.progress);
    animation = tween!.animate(controller!);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      controller!.forward();
    });
    super.initState();
  }

  void setProgress(double newPercentage) {
    tween!.begin = tween!.end;
    tween!.end = newPercentage;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    controller!.addListener(() {
      setState(() {});
    });
    animation = tween!.animate(controller!);
    controller!.forward();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size == null && size == null) {
      return MeasureSize(
          onChange: (s) {
            setState(() {
              size = s;
            });
          },
          child: const SizedBox(width: double.maxFinite, height: double.maxFinite));
    }
    double value = size!.width > size!.height ? size!.height : size!.width;
    return SizedBox(width: value, height: value, child: Stack(children: [SizedBox(width: value, height: value, child: CustomPaint(painter: CustomCircularProgress(width: value, height: value, value: animation!.value / 100))), Center(child: widget.child)]));
    //return CustomPaint(painter: CustomCircularProgress(width: value, height: value, value: animation!.value / 100));
  }
}

class CustomCircularProgress extends CustomPainter {
  final double value;
  final double width, height;
  final double widthStroke = 16;

  CustomCircularProgress({required this.width, required this.height, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(width / 2, height / 2);

    canvas.drawArc(
      Rect.fromCenter(center: center, width: width - 16, height: height - 16),
      vmath.radians(140),
      vmath.radians(260),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.shadow
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8,
    );
    canvas.saveLayer(
      Rect.fromCenter(center: center, width: width, height: height),
      Paint(),
    );

    const Gradient gradient = SweepGradient(
      startAngle: 1.25 * math.pi / 2,
      endAngle: 5.5 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: <Color>[
        AppColors.accent,
        AppColors.graphRed,
      ],
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: width - widthStroke, height: height - widthStroke),
      vmath.radians(140),
      vmath.radians(260 * value),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(Rect.fromLTWH(0.0, 0.0, width, height))
        ..strokeWidth = widthStroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProgressController {
  Function(double) setProgress = (progress) {};
}
