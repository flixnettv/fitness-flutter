import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartData activityData({required List<Color> colors}) {
  return LineChartData(
    gridData: const FlGridData(
      show: false,
      drawVerticalLine: true,
    ),
    titlesData: const FlTitlesData(
      show: false,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
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
        isCurved: false,
        color: colors.first,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: colors.first.withOpacity(0.3),
        ),
      ),
    ],
  );
}
