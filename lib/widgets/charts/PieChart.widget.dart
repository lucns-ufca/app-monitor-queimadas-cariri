import 'dart:math';

import 'package:monitor_queimadas_cariri/models/PredictionCity.model.dart';
import 'package:monitor_queimadas_cariri/utils/AppColors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample extends StatefulWidget {
  final List<PredictionCityModel> predictionCities;
  const PieChartSample({required this.predictionCities, super.key});

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<PieChartSample> {
  final int MAXIMUM_ITEMS = 5;
  int touchedIndex = -1;
  List<PredictionCityModel> predictionCities = [];
  List<Color> colors = [];
  List<double> percentages = [];

  @override
  void initState() {
    List<PredictionCityModel> list = List.from(widget.predictionCities);
    list.sort((a, b) {
      return b.occurredTotal!.compareTo(a.occurredTotal!);
    });
    int total = 0;
    for (PredictionCityModel m in widget.predictionCities) total += m.occurredTotal!;
    var random = Random();
    for (int i = 0; i < MAXIMUM_ITEMS; i++) {
      predictionCities.add(list[i]);
      percentages.add(((list[i].occurredTotal! / total) * 100).toInt().toDouble());
      colors.add(Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.75));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: width * 0.5,
              height: width * 0.5,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: width * 0.1,
                    sections: List.generate(predictionCities.length, (index) {
                      return PieChartSectionData(
                        color: colors[index],
                        value: percentages[index],
                        title: '${percentages[index]}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(predictionCities.length, (index) {
                          if (index == 0) return Indicator(color: colors[index], text: "Juazeiro do Norte", isSquare: false);
                          return Indicator(color: colors[index], text: predictionCities[index].city!, isSquare: false);
                        })))),
          ],
        ));
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
  });
  final Color color;
  final String text;
  final bool isSquare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
