import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_wrapper.dart';
import '../services/session_service.dart';
import '../utils/colors.dart';
import '../localization/translator.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function()? onInit;

  const SplashScreen({this.onInit, Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    await Future.delayed(const Duration(seconds: 2));

    if (widget.onInit != null) {
      await widget.onInit!();
    }

    final isLoggedIn = await SessionService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeWrapper()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.energy_savings_leaf,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                t(context, "app_title"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(context, "app_tagline"),
                style: const TextStyle(color: Colors.white70),
              )
            ],
          ),
        ),
      ),
    );
  }
}
