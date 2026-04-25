import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'pest_screen.dart';
import 'market_screen.dart';
import 'chatbot_screen.dart';
import 'login_screen.dart';
import '../services/session_service.dart';
import 'profile_screen.dart';
import '../localization/translator.dart';

class HomeWrapper extends StatefulWidget {
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int current = 0;

  final pages = [
    DashboardScreen(),
    PestScreen(),
    MarketScreen(),
    ChatbotScreen(),
  ];

  Future<void> _logout() async {
    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  Future<bool> onBackPressed() async {
    if (current != 0) {
      setState(() {
        current = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: onBackPressed,
        child: Scaffold(
          body: Stack(
            children: [
              pages[current],

              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      tooltip: t(context, "profile"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: t(context, "logout"),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: current,
            onDestinationSelected: (i) {
              setState(() {
                current = i;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: t(context, "home"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.camera_alt_outlined),
                selectedIcon: const Icon(Icons.camera_alt),
                label: t(context, "pest"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.show_chart),
                label: t(context, "market"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_outlined),
                selectedIcon: const Icon(Icons.chat),
                label: t(context, "chat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
