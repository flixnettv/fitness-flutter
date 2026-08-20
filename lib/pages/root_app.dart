import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/main.dart';
import 'package:fitness_flutter/pages/home_page.dart';
import 'package:fitness_flutter/pages/devices_page.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  RootAppState createState() => RootAppState();
}

class RootAppState extends State<RootApp> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: const [
        HomePage(),
        _ChartPage(),
        DevicesPage(),
        _ProfilePage(),
      ],
    );
  }

  Widget getFooter() {
    final items = [
      Icons.home,
      Icons.pie_chart,
      Icons.devices,
      Icons.person,
    ];
    final labels = [
      AppStrings.t(context, 'home'),
      AppStrings.t(context, 'charts'),
      AppStrings.t(context, 'devices'),
      AppStrings.t(context, 'profile'),
    ];
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(top: BorderSide(width: 1, color: onSurface.withOpacity(0.06))),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final selected = pageIndex == index;
            return InkWell(
              onTap: () {
                setState(() {
                  pageIndex = index;
                });
              },
              child: Column(
                children: [
                  Icon(
                    items[index],
                    size: 28,
                    color: selected
                        ? AppTheme.third(context)
                        : onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? AppTheme.third(context)
                          : onSurface.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                    child: selected
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.third(context),
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ChartPage extends StatelessWidget {
  const _ChartPage();

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'charts'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t(context, 'activityStatus'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(30),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
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
                      color: primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              AppStrings.t(context, 'sleep'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(30),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
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
                      color: AppTheme.third(context),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final error = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'FitPro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(AppStrings.t(context, 'settings')),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(AppStrings.t(context, 'darkMode')),
                    value: state.isDark,
                    onChanged: (_) {
                      state.toggleDark();
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.language),
                    title: Text(AppStrings.t(context, 'language')),
                    subtitle: Text(state.isArabic ? 'العربية' : 'English'),
                    value: state.isArabic,
                    onChanged: (value) {
                      state.setArabic(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(AppStrings.t(context, 'downloadApp')),
                    subtitle: const Text('Android'),
                    onTap: () async {
                      final uri = Uri.parse(
                          'https://Fitness.hftv.qzz.io/apk/app-release.apk');
                      final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to open download link'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await WgerApiClient.instance.logout();
                  navigator.pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                child: Text(AppStrings.t(context, 'logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}