import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitnar/src/context/app_context.dart';
import 'package:gitnar/src/providers/github_api_provider.dart';
import 'package:gitnar/src/services/auth_service.dart';
import 'package:gitnar/src/models/user_security.dart';
import 'package:gitnar/src/models/github/github_user.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import '../routes.dart';
import 'components/general/message_widget.dart';
import '../views/components/auth_view/github_connection_card.dart';
import '../views/components/auth_view/sonar_token_card.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  final _auth = AuthService();
  final _api = GithubApiProvider();
  bool _githubConnected = false;
  bool _isConnectingGithub = false;
  bool _isSavingToken = false;
  String? _errorMessage;
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    await AppContext.instance.load();
    setState(() {
      _githubConnected =
          AppContext.instance.security?.githubAccessToken.isNotEmpty ?? false;
      _tokenController.text = AppContext.instance.security?.sonarToken ?? '';
    });

    if (AppContext.instance.isFullyConnected) {
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

      // Use provider to get real user
      AppContext.instance.security = UserSecurity(
        githubAccessToken: client.credentials.accessToken,
        sonarToken: AppContext.instance.security?.sonarToken ?? '',
      );

      _api; // make sure it's initialized with new token
      final user = await _api.getCurrentUser();
      AppContext.instance.currentUser = user;

      await AppContext.instance.save();

      setState(() {
        _githubConnected = true;
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

    AppContext.instance.security = UserSecurity(
      githubAccessToken: AppContext.instance.security?.githubAccessToken ?? '',
      sonarToken: token,
    );

    await AppContext.instance.save();

    setState(() {
      _isSavingToken = false;
    });

    _tryFinalize();
  }

  void _tryFinalize() {
    if (AppContext.instance.isFullyConnected) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _debugConnect() async {
    AppContext.instance.security = UserSecurity(
      githubAccessToken: 'debug-token',
      sonarToken: 'debug-token',
    );
    AppContext.instance.currentUser = GithubUser(
      id: 0,
      login: 'dev',
      avatarUrl: '',
    );
    await AppContext.instance.save();
    _navigateToHome();
  }

  void _clearAuth() async {
    await AppContext.instance.clear();
    setState(() {
      _githubConnected = false;
      _tokenController.clear();
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppContext.instance.currentUser;
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
                if (_errorMessage != null)
                  MessageWidget.error(
                    message: _errorMessage!,
                    showCloseButton: true,
                  ),
                GithubConnectionCard(
                  connected: _githubConnected,
                  isConnecting: _isConnectingGithub,
                  username: user?.login,
                  onConnect: _connectGitHub,
                ),
                const SizedBox(height: 24),
                if (_githubConnected)
                  SonarTokenCard(
                    tokenController: _tokenController,
                    tokenSaved:
                        AppContext.instance.security?.sonarToken.isNotEmpty ??
                        false,
                    isSaving: _isSavingToken,
                    onSave: _saveSonarToken,
                  ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _debugConnect,
                      icon: const FaIcon(
                        FontAwesomeIcons.bug,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      label: const Text(
                        'Debug Connect',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    if (_githubConnected ||
                        (AppContext.instance.security?.sonarToken.isNotEmpty ??
                            false))
                      const SizedBox(width: 24),
                    if (_githubConnected ||
                        (AppContext.instance.security?.sonarToken.isNotEmpty ??
                            false))
                      TextButton.icon(
                        onPressed: _clearAuth,
                        icon: const FaIcon(
                          FontAwesomeIcons.trash,
                          size: 16,
                          color: Color(0xFFEF4444),
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
