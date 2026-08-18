import 'package:fitness_flutter/data/latest_workout.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TodayTargetDetailPage extends StatefulWidget {
  const TodayTargetDetailPage({super.key});

  @override
  TodayTargetDetailPageState createState() => TodayTargetDetailPageState();
}

class TodayTargetDetailPageState extends State<TodayTargetDetailPage> {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 22,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const Text(
              "Activity Tracker",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Icon(
                    Icons.more_horiz,
                    size: 22,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    final size = MediaQuery.of(context).size;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.secondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.t(context, 'todayTarget'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.secondary(context),
                                AppTheme.primary(context),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.card(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset("assets/images/glass.svg"),
                                Text(
                                  AppStrings.t(context, 'waterIntake'),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.card(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/foot_step.svg",
                                ),
                                const Text(
                                  "Foot Steps",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Activity Progress",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 20,
                    blurRadius: 10,
                    color: onSurface.withOpacity(0.05),
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(weekly.length, (index) {
                    return Column(
                      children: [
                        Flexible(
                          child: Stack(
                            children: [
                              Container(
                                width: 20,
                                height: size.height,
                                decoration: BoxDecoration(
                                  color: AppTheme.textField(context),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 20,
                                  height: size.height *
                                      (weekly[index]['count'] as double),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: weekly[index]['color']
                                          as List<Color>,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          weekly[index]['day'] as String,
                          style: const TextStyle(fontSize: 13),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Latest Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Column(
              children: List.generate(latestActivityJson.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      boxShadow: [
                        BoxShadow(
                          color: onSurface.withOpacity(0.05),
                          spreadRadius: 20,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      latestActivityJson[index]['img']
                                          as String,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Container(
                                height: 55,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      latestActivityJson[index]['title']
                                          as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      latestActivityJson[index]['time_ago']
                                          as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.more_vert,
                            size: 15,
                            color: onSurface.withOpacity(0.5),
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
    );
  }
}
