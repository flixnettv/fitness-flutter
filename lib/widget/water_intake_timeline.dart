import 'package:fitness_flutter/data/water_intake.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WaterIntakeTimeLine extends StatelessWidget {
  const WaterIntakeTimeLine({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: List.generate(waterIntakeJson.length, (index) {
        if (index != waterIntakeJson.length - 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.third(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    waterIntakeJson[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  height: 25,
                  width: 1,
                  decoration: BoxDecoration(
                    color: AppTheme.third(context),
                  ),
                ),
              ),
              const SizedBox(height: 2),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.third(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    waterIntakeJson[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      }),
    );
  }
}
