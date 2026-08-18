import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WateIntakeProgressBar extends StatelessWidget {
  const WateIntakeProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: 20,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppTheme.textField(context),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: 20,
            height: size.height * 0.18,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [AppTheme.fourth(context), AppTheme.primary(context)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
