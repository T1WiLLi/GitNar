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
  String _sonarProvider = 'SonarQube';
  bool _githubConnected = false;
  bool _sonarConnected = false;

  Future<void> _updateGithub() async {
    final username = await _auth.connectGitHub();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGithubConnected', true);
    await prefs.setString('githubUsername', username);
    setState(() => _githubConnected = true);
    _tryFinalizeAuth();
  }

  Future<void> _updateSonar() async {
    final username = await _auth.connectSonar(_sonarProvider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSonarConnected', true);
    await prefs.setString('sonarUsername', username);
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
    prefs
      ..setBool('isGithubConnected', true)
      ..setString('githubUsername', 'dev')
      ..setBool('isSonarConnected', true)
      ..setString('sonarUsername', 'dev')
      ..setBool('isAuthenticated', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required bool isConnected,
    required VoidCallback onConnect,
    required String description,
    Widget? trailing,
  }) {
    return Container(
      width: 400,
      height: 320, // increased to prevent overflow
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status and info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              Tooltip(
                message:
                    'We need to connect to $title to retrieve your repositories and analyze your code quality.',
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Icon and title
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const Spacer(),

          // Connect button and trailing widget
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isConnected ? null : onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Connect',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 16), trailing],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSonarProviderSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _sonarProvider,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          size: 18,
          color: Colors.grey.shade600,
        ),
        items: const [
          DropdownMenuItem(value: 'SonarQube', child: Text('SonarQube')),
          DropdownMenuItem(value: 'SonarCloud', child: Text('SonarCloud')),
        ],
        onChanged: (v) {
          if (v != null) setState(() => _sonarProvider = v);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Text(
                  'Authentication',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 40, // bumped up
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect to your tools to start',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 60),

                // Service cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildServiceCard(
                      title: 'GitHub',
                      icon: Icons.code,
                      isConnected: _githubConnected,
                      onConnect: _updateGithub,
                      description: 'Access your repositories and code',
                    ),

                    const SizedBox(width: 40),

                    _buildServiceCard(
                      title: 'Sonar',
                      icon: Icons.analytics,
                      isConnected: _sonarConnected,
                      onConnect: _updateSonar,
                      description: 'Analyze code quality and security',
                      trailing: _buildSonarProviderSelector(),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Debug button
                TextButton(
                  onPressed: _debugConnect,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text(
                    'debug connect',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
