import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitnar/src/services/auth_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  final _auth = AuthService();
  bool _githubConnected = false;
  bool _isConnectingGithub = false;
  bool _isSavingToken = false;
  String? _githubUsername;
  String? _errorMessage;
  final TextEditingController _tokenController = TextEditingController();
  bool _sonarTokenSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('githubAccessToken');
    final username = prefs.getString('githubUsername');
    final sonarToken = prefs.getString('sonarToken');

    if (accessToken != null && username != null) {
      final isValid = await _auth.validateGitHubToken(accessToken);
      if (isValid) {
        setState(() {
          _githubConnected = true;
          _githubUsername = username;
        });
      } else {
        await prefs.remove('githubAccessToken');
        await prefs.remove('githubUsername');
      }
    }

    setState(() {
      _sonarTokenSaved = sonarToken != null && sonarToken.isNotEmpty;
      if (_sonarTokenSaved) _tokenController.text = sonarToken!;
    });

    if (_githubConnected && _sonarTokenSaved) {
      _navigateToHome();
    }
  }

  Future<void> _connectGitHub() async {
    setState(() {
      _isConnectingGithub = true;
      _errorMessage = null;
    });

    try {
      final result = await _auth.connectGitHub();
      final client = result['client'] as oauth2.Client;
      final username = result['username'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'githubAccessToken',
        client.credentials.accessToken,
      );
      await prefs.setString('githubUsername', username);

      setState(() {
        _githubConnected = true;
        _githubUsername = username;
        _isConnectingGithub = false;
      });

      _tryFinalize();
    } catch (e) {
      setState(() {
        _isConnectingGithub = false;
        _errorMessage = 'GitHub connection failed: $e';
      });
    }
  }

  Future<void> _saveSonarToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid SonarQube token';
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
        _sonarTokenSaved = true;
        _isSavingToken = false;
      });

      _tryFinalize();
    } catch (e) {
      setState(() {
        _isSavingToken = false;
        _errorMessage = 'Failed to save SonarQube token: $e';
      });
    }
  }

  Future<void> _tryFinalize() async {
    final prefs = await SharedPreferences.getInstance();
    final githubToken = prefs.getString('githubAccessToken');
    final sonarToken = prefs.getString('sonarToken');

    if (githubToken != null && sonarToken != null && sonarToken.isNotEmpty) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  Future<void> _debugConnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('githubAccessToken', 'debug-token');
    await prefs.setString('githubUsername', 'dev');
    await prefs.setString('sonarToken', 'dev-token');
    _navigateToHome();
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('githubAccessToken');
    await prefs.remove('githubUsername');
    await prefs.remove('sonarToken');

    setState(() {
      _githubConnected = false;
      _githubUsername = null;
      _sonarTokenSaved = false;
      _errorMessage = null;
      _tokenController.clear();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF1E3A8A), Color(0xFF1F2937)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.github,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GitNar',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            color: Colors.white,
                            shadows: [
                              const Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 14,
                      ),
                    ),
                  ),

                // GitHub Connection
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.github,
                            color: Color(0xFF60A5FA),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GitHub',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: (_githubConnected || _isConnectingGithub)
                            ? null
                            : _connectGitHub,
                        icon: _isConnectingGithub
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : _githubConnected
                            ? const FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: Color(0xFF16A34A),
                                size: 16,
                              )
                            : const SizedBox.shrink(),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_githubConnected) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isConnectingGithub
                                    ? 'Connecting...'
                                    : _githubConnected
                                    ? 'Logged in as $_githubUsername'
                                    : 'Connect to GitHub',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _githubConnected ? Colors.white : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _githubConnected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(300, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (_githubConnected)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.shield,
                              color: Color(0xFFF97316),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SonarQube',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _tokenController,
                          obscureText: true,
                          enabled: !_sonarTokenSaved,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // larger input text
                            height: 1.3,
                          ),
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16, // larger floating label
                            ),
                            filled: true,
                            fillColor: const Color(0xFF374151),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18, // taller field
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _sonarTokenSaved
                                ? const FaIcon(
                                    FontAwesomeIcons.circleCheck,
                                    color: Color(0xFF16A34A),
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: (_sonarTokenSaved || _isSavingToken)
                              ? null
                              : _saveSonarToken,
                          icon: _isSavingToken
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.floppyDisk,
                                  size: 18,
                                ),
                          label: Text(
                            _isSavingToken
                                ? 'Saving...'
                                : _sonarTokenSaved
                                ? 'Token Saved'
                                : 'Save SonarQube Token',
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _sonarTokenSaved
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Debug and Clear Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _debugConnect,
                      icon: const FaIcon(
                        FontAwesomeIcons.bug,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                      label: const Text(
                        'Debug Connect',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    if (_githubConnected || _sonarTokenSaved)
                      const SizedBox(width: 24),
                    if (_githubConnected || _sonarTokenSaved)
                      TextButton.icon(
                        onPressed: _clearAuth,
                        icon: const FaIcon(
                          FontAwesomeIcons.trash,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        label: const Text(
                          'Clear Auth',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
