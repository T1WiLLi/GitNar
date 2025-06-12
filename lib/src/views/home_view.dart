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
  String? _sonarUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;
    if (!isAuth) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.auth);
      return;
    }
    setState(() {
      _ghUser = prefs.getString('githubUsername');
      _sonarUser = prefs.getString('sonarUsername');
    });
  }

  Future<void> _disconnect() async {
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
            if (_ghUser != null)
              Text('GitHub: \$\_ghUser', style: TextStyle(fontSize: 18)),
            if (_sonarUser != null)
              Text('Sonar: \$\_sonarUser', style: TextStyle(fontSize: 18)),
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
