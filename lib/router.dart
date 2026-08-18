import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/root_app.dart';
import 'pages/today_target_detail_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/root_app':
      return MaterialPageRoute(builder: (context) => const RootApp());
    case '/login':
      return MaterialPageRoute(builder: (context) => const LoginPage());
    case '/register':
      return MaterialPageRoute(builder: (context) => const RegisterPage());
    case '/today_target_detail':
      return MaterialPageRoute(builder: (context) => const TodayTargetDetailPage());
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(body: SizedBox()),
      );
  }
}
