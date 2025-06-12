import 'package:flutter/material.dart';
import 'package:gitnar/src/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;
    if (!isAuth && mounted) {
      Navigator.pushReplacementNamed(context, Routes.auth);
    }
  }

  Future<void> _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Home Screen',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _disconnect,
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
