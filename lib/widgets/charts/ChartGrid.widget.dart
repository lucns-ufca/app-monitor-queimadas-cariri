import 'package:app_monitor_queimadas/utils/AppColors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartGrid extends StatefulWidget {
  const ChartGrid({super.key});

  @override
  State<ChartGrid> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<ChartGrid> {
  List<Color> gradientColors = [
    AppColors.accent,
    AppColors.graphRed,
  ];
  List<Color> gradientColors2 = [
    Colors.white,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 4,
              top: 20,
              bottom: 8,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        )
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: AppColors.textNormal);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('fev', style: style);
        break;
      case 2:
        text = const Text('mar', style: style);
        break;
      case 3:
        text = const Text('abri', style: style);
        break;
      case 4:
        text = const Text('mai', style: style);
        break;
      case 5:
        text = const Text('jun', style: style);
        break;
      case 6:
        text = const Text('jul', style: style);
        break;
      case 7:
        text = const Text('ago', style: style);
        break;
      case 8:
        text = const Text('set', style: style);
        break;
      case 9:
        text = const Text('out', style: style);
        break;
      case 10:
        text = const Text('nov', style: style);
        break;
      default:
        text = const Text(' ', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: AppColors.textNormal);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 1:
        text = '100';
        break;
      case 2:
        text = '200';
        break;
      case 3:
        text = '300';
        break;
      case 4:
        text = '400';
        break;
      case 5:
        text = '500';
        break;
      case 6:
        text = '600';
        break;
      default:
        return const SizedBox();
    }

    return Padding(padding: const EdgeInsets.only(right: 8), child: Text(text, style: style, textAlign: TextAlign.right));
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.graphLines,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.graphLines,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 4),
            FlSpot(2, 6),
            FlSpot(3, 4),
            FlSpot(4, 3),
            FlSpot(5, 1),
            FlSpot(6, 4),
            FlSpot(7, 2),
            FlSpot(8, 1),
            FlSpot(9, 2),
            FlSpot(10, 3),
            FlSpot(11, 5),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors2.map((color) => color.withOpacity(0.2)).toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 4),
            FlSpot(1, 2),
            FlSpot(2, 5),
            FlSpot(3, 3),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 6),
            FlSpot(7, 4),
            FlSpot(8, 2),
            FlSpot(9, 1),
            FlSpot(10, 4),
            FlSpot(11, 2),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.5)).toList(),
            ),
          ),
        )
      ],
    );
  }
}
