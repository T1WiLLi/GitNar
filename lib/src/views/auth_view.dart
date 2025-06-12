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
  bool _isConnecting = false;
  bool _isSavingToken = false;
  String? _githubUsername;
  String? _errorMessage;
  final TextEditingController _tokenController = TextEditingController();
  bool _tokenSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;
    final username = prefs.getString('githubUsername');
    final token = prefs.getString('sonarToken');

    setState(() {
      _connected = isAuth && username != null;
      _githubUsername = username;
      _tokenSaved = token != null && token.isNotEmpty;
    });

    // If everything is ready, navigate home
    if (_connected && _tokenSaved) {
      _navigateToHome();
    }
  }

  Future<void> _connectGitHub() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final username = await _auth.connectGitHub();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('githubUsername', username);

      setState(() {
        _connected = true;
        _githubUsername = username;
        _isConnecting = false;
      });

      _tryFinalize();
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'GitHub connection failed: ${e.toString()}';
      });
    }
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid token';
      });
      return;
    }

    setState(() {
      _isSavingToken = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sonarToken', token);

      setState(() {
        _tokenSaved = true;
        _isSavingToken = false;
      });

      _tryFinalize();
    } catch (e) {
      setState(() {
        _isSavingToken = false;
        _errorMessage = 'Failed to save token: ${e.toString()}';
      });
    }
  }

  Future<void> _tryFinalize() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getBool('isAuthenticated') ?? false;
    final token = prefs.getString('sonarToken');

    if (auth && token != null && token.isNotEmpty) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  Future<void> _debugConnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('githubUsername', 'dev');
    await prefs.setString('sonarToken', 'dev-token');
    _navigateToHome();
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('githubUsername');
    await prefs.remove('sonarToken');

    setState(() {
      _connected = false;
      _githubUsername = null;
      _tokenSaved = false;
      _errorMessage = null;
    });

    _tokenController.clear();
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

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // GitHub connection
              ElevatedButton(
                onPressed: (_connected || _isConnecting)
                    ? null
                    : _connectGitHub,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(240, 48),
                  backgroundColor: _connected ? Colors.green : null,
                ),
                child: _isConnecting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Connecting...'),
                        ],
                      )
                    : Text(
                        _connected
                            ? 'GitHub Connected: $_githubUsername'
                            : 'Connect GitHub',
                      ),
              ),

              const SizedBox(height: 16),

              if (_connected) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logged in as $_githubUsername',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sonar token input
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: 'Sonar Token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _tokenSaved
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  obscureText: true,
                  enabled: !_tokenSaved,
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: (_tokenSaved || _isSavingToken)
                      ? null
                      : _saveToken,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(240, 48),
                    backgroundColor: _tokenSaved ? Colors.green : null,
                  ),
                  child: _isSavingToken
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Saving...'),
                          ],
                        )
                      : Text(_tokenSaved ? 'Token Saved' : 'Save Sonar Token'),
                ),
              ],

              const SizedBox(height: 24),

              // Debug and clear buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _debugConnect,
                    child: const Text('Debug Connect'),
                  ),
                  const SizedBox(width: 16),
                  if (_connected || _tokenSaved)
                    TextButton(
                      onPressed: _clearAuth,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Clear Auth'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
