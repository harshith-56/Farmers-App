import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_wrapper.dart';
import '../services/session_service.dart';
import '../localization/translator.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> handleSubmit() async {
    if (!isLogin && nameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = t(context, "enter_name");
      });
      return;
    }

    if (phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = t(context, "fill_all_fields");
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    Map<String, dynamic> result;

    if (isLogin) {
      result = await ApiService.login(
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
    } else {
      result = await ApiService.signup(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
    }

    if (result["success"] != true) {
      setState(() {
        isLoading = false;
        errorMessage = result["message"] ?? t(context, "something_wrong");
      });
      return;
    }

    final profile = await ApiService.fetchProfile(
      phoneController.text.trim(),
    );

    if (profile["success"] == true) {
      await SessionService.saveUser(
        phone: profile["phone"],
        name: profile["name"],
        language: profile["language"] ?? "en",
      );
    } else {
      await SessionService.saveUser(
        phone: phoneController.text.trim(),
        name: isLogin ? "" : nameController.text.trim(),
        language: "en",
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                isLogin
                    ? t(context, "welcome_back")
                    : t(context, "create_account"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              if (!isLogin)
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: t(context, "name"),
                    border: const OutlineInputBorder(),
                  ),
                ),

              if (!isLogin) const SizedBox(height: 16),

              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: t(context, "phone"),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t(context, "password"),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSubmit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin
                      ? t(context, "login")
                      : t(context, "signup")),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? t(context, "no_account")
                        : t(context, "have_account"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        errorMessage = null;
                      });
                    },
                    child: Text(isLogin
                        ? t(context, "signup")
                        : t(context, "login")),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
