import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.t(context, 'invalidCredentials'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    final success = await WgerApiClient.instance.login(username, password);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/root_app', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.t(context, 'invalidCredentials'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondary(context).withOpacity(0.25),
              AppTheme.primary(context).withOpacity(0.25),
            ],
          ),
        ),
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    final size = MediaQuery.of(context).size;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                height: (size.height - 60) * 0.5,
                child: Column(
                  children: [
                    const Text(
                      "Hey there,",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppStrings.t(context, 'welcomeBack'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.textField(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              child: TextField(
                                controller: _usernameController,
                                cursorColor: onSurface.withOpacity(0.5),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: AppStrings.t(context, 'username'),
                                  border: InputBorder.none,
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
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.textField(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              child: TextField(
                                controller: _passwordController,
                                cursorColor: onSurface.withOpacity(0.5),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: AppStrings.t(context, 'password'),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: onSurface.withOpacity(0.5),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppStrings.t(context, 'forgotPassword'),
                      style: const TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              ),

              Container(
                height: (size.height - 60) * 0.5,
                child: Column(
                  children: [
                    InkWell(
                      onTap: _isLoading ? null : _login,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.secondary(context),
                              AppTheme.primary(context),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else ...[
                              const Icon(
                                Icons.arrow_forward_sharp,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                AppStrings.t(context, 'login'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Flexible(
                          child: Divider(
                            thickness: 0.8,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text("Or"),
                        const SizedBox(
                          width: 5,
                        ),
                        const Flexible(
                          child: Divider(
                            thickness: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: onSurface.withOpacity(0.1),
                            ),
                          ),
                          child: const Center(
                            child: SvgPicture.asset(
                              "assets/images/google_icon.svg",
                              width: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: onSurface.withOpacity(0.1),
                            ),
                          ),
                          child: const Center(
                            child: SvgPicture.asset(
                              "assets/images/facebook_icon.svg",
                              width: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.t(context, 'dontHaveAccount')),
                        const SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            AppStrings.t(context, 'signUp'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
