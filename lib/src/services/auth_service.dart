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

    if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $authUrl');
    }

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      _redirectUri.port,
    );

    try {
      await for (final request in server) {
        final uri = request.uri;

        if (uri.path == '/github/callback') {
          request.response
            ..statusCode = 200
            ..headers.set('Content-Type', 'text/html')
            ..write('''
              <html>
                <body>
                  <h3>Authentication successful!</h3>
                  <p>You may close this window.</p>
                  <script>window.close();</script>
                </body>
              </html>
            ''');
          await request.response.close();

          await server.close();

          return grant.handleAuthorizationResponse(uri.queryParameters);
        } else {
          request.response
            ..statusCode = 404
            ..write('Not found');
          await request.response.close();
        }
      }
    } catch (e) {
      await server.close();
      rethrow;
    }

    throw Exception('Authentication was cancelled or failed');
  }

  Future<String> connectGitHub() async {
    try {
      final client = await _authenticate();
      final resp = await client.get(Uri.parse('https://api.github.com/user'));

      if (resp.statusCode != 200) {
        throw Exception('Failed to get user info: ${resp.statusCode}');
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final username = data['login'] as String?;

      if (username == null) {
        throw Exception('Username not found in GitHub response');
      }

      return username;
    } catch (e) {
      throw Exception('GitHub authentication failed: $e');
    }
  }
}
