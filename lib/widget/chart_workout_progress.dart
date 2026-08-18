import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartData workoutProgressData({
  required List<Color> colors,
  required Color third,
}) {
  return LineChartData(
    gridData: FlGridData(
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Colors.transparent,
          strokeWidth: 0.1,
        );
      },
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color(0xff37434d),
          strokeWidth: 0.1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 1:
                text = 'Mon';
                break;
              case 3:
                text = 'Tue';
                break;
              case 5:
                text = 'Wed';
                break;
              case 7:
                text = 'Thu';
                break;
              case 9:
                text = 'Fri';
                break;
              case 11:
                text = 'Sat';
                break;
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(text, style: const TextStyle(fontSize: 10)),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false, reservedSize: 28),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 1:
                text = '0%';
                break;
              case 2:
                text = '20%';
                break;
              case 3:
                text = '60%';
                break;
              case 4:
                text = '80%';
                break;
              case 5:
                text = '100%';
                break;
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(text, style: const TextStyle(fontSize: 10)),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
          FlSpot(6.8, 3.1),
          FlSpot(8, 4),
          FlSpot(9.5, 3),
          FlSpot(11, 4),
        ],
        isCurved: true,
        color: colors.first,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      ),
      LineChartBarData(
        spots: const [
          FlSpot(0, 1.5),
          FlSpot(2.5, 1),
          FlSpot(3, 5),
          FlSpot(5, 2),
          FlSpot(7, 4),
          FlSpot(8, 3),
          FlSpot(11, 4),
        ],
        isCurved: true,
        color: third.withOpacity(0.5),
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      ),
    ],
  );
}
