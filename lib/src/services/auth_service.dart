import 'dart:io';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

/// Handles OAuth flows using PKCE (no client-secret embedded)
class AuthService {
  // GitHub
  static const _clientId = 'Ov23liE4ln8SrtNYwSHA';
  static final _authEndpoint = Uri.parse(
    'https://github.com/login/oauth/authorize',
  );
  static final _tokenEndpoint = Uri.parse(
    'https://github.com/login/oauth/access_token',
  );
  static final _redirectUri = Uri.parse(
    'http://localhost:8080/github/callback',
  );
  static const _scopes = ['read:user'];

  Future<oauth2.Client> _authenticate() async {
    final grant = oauth2.AuthorizationCodeGrant(
      _clientId,
      _authEndpoint,
      _tokenEndpoint,
    );
    final authUrl = grant.getAuthorizationUrl(_redirectUri, scopes: _scopes);
    if (!await launchUrl(authUrl)) {
      throw Exception('Could not launch \$authUrl');
    }

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      _redirectUri.port,
    );
    final request = await server.first;
    final fullUri = request.uri;
    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html')
      ..write('<h3>You may close this window.</h3>');
    await request.response.close();
    await server.close();

    return grant.handleAuthorizationResponse(fullUri.queryParameters);
  }

  Future<String> connectGitHub() async {
    final client = await _authenticate();
    final resp = await client.get(Uri.parse('https://api.github.com/user'));
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return data['login'] as String;
  }
}
