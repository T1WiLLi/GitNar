import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  String _sonarProvider = 'SonarQube';
  bool _githubConnected = false;
  bool _sonarConnected = false;

  Future<void> _updateGithub() async {
    // TODO: Wire up GitHub OAuth
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGithubConnected', true);
    setState(() => _githubConnected = true);
    _tryFinalizeAuth();
  }

  Future<void> _updateSonar() async {
    // TODO: Wire up Sonar OAuth based on provider
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSonarConnected', true);
    setState(() => _sonarConnected = true);
    _tryFinalizeAuth();
  }

  Future<void> _tryFinalizeAuth() async {
    if (_githubConnected && _sonarConnected) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  Future<void> _debugConnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGithubConnected', true);
    await prefs.setBool('isSonarConnected', true);
    await prefs.setBool('isAuthenticated', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect Your Account',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateGithub,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: _githubConnected ? Colors.green : null,
              ),
              child: Text(
                _githubConnected ? 'GitHub Connected' : 'Connect to GitHub',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _updateSonar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sonarConnected ? Colors.green : null,
                  ),
                  child: Text(
                    _sonarConnected ? 'Sonar Connected' : 'Connect to Sonar',
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _sonarProvider,
                  items: const [
                    DropdownMenuItem(
                      value: 'SonarQube',
                      child: Text('SonarQube'),
                    ),
                    DropdownMenuItem(
                      value: 'SonarCloud',
                      child: Text('SonarCloud'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sonarProvider = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: _debugConnect,
              child: const Text('Debug Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
