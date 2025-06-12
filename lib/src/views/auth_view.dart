// lib/src/screens/auth_view.dart
import 'package:flutter/material.dart';
import 'package:gitnar/src/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  final _auth = AuthService();
  bool _connected = false;
  final TextEditingController _tokenController = TextEditingController();
  bool _tokenSaved = false;

  Future<void> _connectGitHub() async {
    final username = await _auth.connectGitHub();
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..setBool('isAuthenticated', true)
      ..setString('githubUsername', username);
    setState(() => _connected = true);
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sonarToken', token);
    setState(() => _tokenSaved = true);
    _tryFinalize();
  }

  Future<void> _tryFinalize() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getBool('isAuthenticated') ?? false;
    final token = prefs.getString('sonarToken');
    if (auth && token != null && token.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  Future<void> _debugConnect() async {
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..setBool('isAuthenticated', true)
      ..setString('githubUsername', 'dev')
      ..setString('sonarToken', 'dev-token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Authentication',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _connected ? null : _connectGitHub,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(240, 48),
                ),
                child: Text(_connected ? 'GitHub Connected' : 'Connect GitHub'),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: 'Sonar Token',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _tokenSaved ? null : _saveToken,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(240, 48),
                ),
                child: Text(_tokenSaved ? 'Token Saved' : 'Save Sonar Token'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _debugConnect,
                child: const Text('debug connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
