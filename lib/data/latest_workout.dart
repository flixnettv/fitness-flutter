import 'package:fitness_flutter/theme/colors.dart';

const List<Map<String, dynamic>> latestWorkoutJson = [
  {
    "img": "assets/images/workout_1.png",
    "title": "Fullbody Workout",
    "description": "180 Calories Burn | 20minutes",
    "progressBar": 0.3,
  },
  {
    "img": "assets/images/workout_2.png",
    "title": "Lowerbody Workout",
    "description": "200 Calories Burn | 30minutes",
    "progressBar": 0.4,
  },
  {
    "img": "assets/images/workout_3.png",
    "title": "Ab Workout",
    "description": "180 Calories Burn | 20minutes",
    "progressBar": 0.2,
  },
];

const List<Map<String, dynamic>> latestActivityJson = [
  {
    "img": "assets/images/drinking_water.png",
    "title": "Drinking 300ml Water",
    "time_ago": "About 3 minutes ago",
  },
  {
    "img": "assets/images/eat_snack.png",
    "title": "Eat Snack (Fitbar)",
    "time_ago": "About 10 minutes ago",
  },
];

const List<Map<String, dynamic>> weekly = [
  {
    "day": "Sun",
    "count": 0.1,
    "color": [AppColors.lightSecondary, AppColors.lightPrimary],
  },
  {
    "day": "Mon",
    "count": 0.08,
    "color": [AppColors.lightFourth, AppColors.lightThird],
  },
  {
    "day": "Tue",
    "count": 0.12,
    "color": [AppColors.lightSecondary, AppColors.lightPrimary],
  },
  {
    "day": "Wed",
    "count": 0.075,
    "color": [AppColors.lightFourth, AppColors.lightThird],
  },
  {
    "day": "Thu",
    "count": 0.09,
    "color": [AppColors.lightSecondary, AppColors.lightPrimary],
  },
  {
    "day": "Fri",
    "count": 0.05,
    "color": [AppColors.lightFourth, AppColors.lightThird],
  },
  {
    "day": "Sat",
    "count": 0.097,
    "color": [AppColors.lightSecondary, AppColors.lightPrimary],
  },
];
