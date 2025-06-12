import 'package:flutter/material.dart';
import 'package:gitnar/src/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  String? _ghUser;
  String? _sonarToken;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getBool('isAuthenticated') ?? false;
    if (!auth) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.auth);
      return;
    }
    if (!mounted) return;
    setState(() {
      _ghUser = prefs.getString('githubUsername');
      _sonarToken = prefs.getString('sonarToken');
    });
  }

  void _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome,', style: Theme.of(context).textTheme.headlineLarge),
            if (_ghUser != null) Text('GitHub: \$_ghUser'),
            if (_sonarToken != null) Text('Sonar Token: \$_sonarToken'),
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
