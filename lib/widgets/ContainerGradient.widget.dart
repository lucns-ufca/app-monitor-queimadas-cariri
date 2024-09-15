import 'package:flutter/material.dart';

class ContainerGradient extends StatefulWidget {
  final Duration duration;
  final List<Color> colors;
  final Widget child;

  const ContainerGradient({super.key, required this.duration, required this.colors, required this.child});

  @override
  State<ContainerGradient> createState() => _FancyContainer();
}

class _FancyContainer extends State<ContainerGradient> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(children: [
      SizedBox(
          width: width,
          height: height,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      tileMode: TileMode.repeated,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      transform: SlideGradient(
                        controller.value,
                        height * (height / width),
                      ),
                      colors: widget.colors,
                    ),
                  ));
            },
          )),
      widget.child
    ]);
  }
}

class SlideGradient implements GradientTransform {
  final double value;
  final double offset;
  const SlideGradient(this.value, this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dist = value * (bounds.width + offset);
    return Matrix4.identity()..translate(-dist);
  }
}
