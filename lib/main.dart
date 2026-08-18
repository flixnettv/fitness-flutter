import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? true;
  final isArabic = prefs.getString('language') != 'en';
  final loggedIn = prefs.getString('wger_access_token') != null;
  runApp(FitProApp(
    prefs: prefs,
    isDark: isDark,
    isArabic: isArabic,
    loggedIn: loggedIn,
  ));
}

class AppState extends ChangeNotifier {
  AppState(this._prefs);

  final SharedPreferences _prefs;

  bool _isDark = true;
  bool _isArabic = true;

  bool get isDark => _isDark;
  bool get isArabic => _isArabic;
  Locale get locale => _isArabic ? const Locale('ar') : const Locale('en');

  void init({required bool isDark, required bool isArabic}) {
    _isDark = isDark;
    _isArabic = isArabic;
  }

  Future<void> toggleDark() async {
    _isDark = !_isDark;
    await _prefs.setBool('dark_mode', _isDark);
    notifyListeners();
  }

  Future<void> setArabic(bool value) async {
    _isArabic = value;
    await _prefs.setString('language', value ? 'ar' : 'en');
    notifyListeners();
  }
}

class FitProApp extends StatelessWidget {
  const FitProApp({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.isArabic,
    required this.loggedIn,
  });

  final SharedPreferences prefs;
  final bool isDark;
  final bool isArabic;
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(prefs)
        ..init(isDark: isDark, isArabic: isArabic),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'FitPro',
            debugShowCheckedModeBanner: false,
            initialRoute: loggedIn ? '/root_app' : '/login',
            onGenerateRoute: generateRoute,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
            locale: state.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
