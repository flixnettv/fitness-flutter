import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:fitness_flutter/widget/chart_activity_status.dart';
import 'package:fitness_flutter/widget/chart_sleep.dart';
import 'package:fitness_flutter/widget/chart_workout_progress.dart';
import 'package:fitness_flutter/widget/water_intake_progressbar.dart';
import 'package:fitness_flutter/widget/water_intake_timeline.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _loading = true;
  String _username = 'FitPro';
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final results =
        await WgerApiClient.instance.getExercises(lang: isAr ? 'ar' : 'en');
    final user = await WgerApiClient.instance.getUser();
    if (!mounted) return;
    setState(() {
      _exercises = results.whereType<Map<String, dynamic>>().toList();
      final name = _usernameFrom(user);
      if (name != null) _username = name;
      _loading = false;
    });
  }

  String? _usernameFrom(Map<String, dynamic>? user) {
    if (user == null) return null;
    for (final key in ['username', 'user', 'first_name']) {
      final v = user[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  String _exerciseName(Map<String, dynamic> ex) {
    final translations = ex['translations'] as List<dynamic>? ?? const [];
    if (translations.isNotEmpty && translations[0] is Map<String, dynamic>) {
      final name = (translations[0] as Map<String, dynamic>)['name'];
      if (name is String && name.isNotEmpty) return name;
    }
    return AppStrings.t(context, 'exercises');
  }

  String _exerciseCategory(Map<String, dynamic> ex) {
    final category = ex['category'];
    if (category is Map) {
      final name = category['name'];
      if (name is String && name.isNotEmpty) return name;
    }
    return AppStrings.t(context, 'exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    final size = MediaQuery.of(context).size;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final shadowColor = Theme.of(context).colorScheme.shadow;
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(context, 'welcomeBack'),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: onSurface.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.notifications_none),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                height: 145,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondary(context),
                      AppTheme.primary(context),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.t(context, 'bmi'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                AppStrings.t(context, 'normalWeight'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 95,
                                height: 35,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.fourth(context),
                                      AppTheme.third(context),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    AppStrings.t(context, 'viewMore'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.fourth(context),
                              AppTheme.third(context),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "20,3",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.secondary(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t(context, 'todayTarget'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/today_target_detail");
                        },
                        child: Container(
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.secondary(context),
                                AppTheme.primary(context),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.t(context, 'check'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                AppStrings.t(context, 'activityStatus'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.secondary(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      child: LineChart(
                        activityData(
                          colors: [
                            AppTheme.secondary(context),
                            AppTheme.primary(context),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        AppStrings.t(context, 'heartRate'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Container(
                    width: (size.width - 80) / 2,
                    height: 320,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withOpacity(0.05),
                          spreadRadius: 20,
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const WateIntakeProgressBar(),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.t(context, 'waterIntake'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      AppStrings.t(context, 'realTimeUpdates'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const WaterIntakeTimeLine()
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Container(
                        width: (size.width - 80) / 2,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.card(context),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor.withOpacity(0.05),
                              spreadRadius: 20,
                              blurRadius: 10,
                              offset: const Offset(0, 10),
                            )
                          ],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.t(context, 'sleep'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: LineChart(
                                  sleepData(
                                    colors: [AppTheme.primary(context)],
                                    third: AppTheme.third(context),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: (size.width - 80) / 2,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.card(context),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor.withOpacity(0.05),
                              spreadRadius: 20,
                              blurRadius: 10,
                              offset: const Offset(0, 10),
                            )
                          ],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.t(context, 'calories'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    colors: [
                                      AppTheme.fourth(context),
                                      AppTheme.primary(context).withOpacity(0.5),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primary(context),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "230 Cal",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.t(context, 'workoutProgress'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 95,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondary(context),
                          AppTheme.primary(context),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.t(context, 'weekly'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(0.05),
                      spreadRadius: 20,
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    )
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: LineChart(
                  workoutProgressData(
                    colors: [AppTheme.primary(context)],
                    third: AppTheme.third(context),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.t(context, 'latestWorkout'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.t(context, 'seeMore'),
                    style: TextStyle(
                      fontSize: 15,
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              _loading
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(AppStrings.t(context, 'loading')),
                      ),
                    )
                  : _exercises.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(AppStrings.t(context, 'noData')),
                          ),
                        )
                      : Column(
                          children: List.generate(_exercises.length, (index) {
                            final ex = _exercises[index];
                            final progress = (index % 5 + 1) / 10.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.card(context),
                                  boxShadow: [
                                    BoxShadow(
                                      color: shadowColor.withOpacity(0.05),
                                      spreadRadius: 20,
                                      blurRadius: 10,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondary(context)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: AppTheme.third(context),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 55,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _exerciseName(ex),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _exerciseCategory(ex),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: onSurface
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: size.width,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: AppTheme.textField(
                                                          context),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        size.width * progress,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      gradient: LinearGradient(
                                                          colors: [
                                                        AppTheme.primary(
                                                            context),
                                                        AppTheme.secondary(
                                                            context),
                                                      ]),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primary(context),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 11,
                                            color: AppTheme.primary(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        )
            ],
          ),
        ),
      ),
    );
  }
}
