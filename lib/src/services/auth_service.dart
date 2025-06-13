import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gitnar/src/utils/resource_loader.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final _clientId = dotenv.env['CLIENT_ID'] ?? '';
  static final _clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
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

  Future<Map<String, dynamic>> _authenticate() async {
    final httpClient = http.Client();
    final grant = oauth2.AuthorizationCodeGrant(
      _clientId,
      _authEndpoint,
      _tokenEndpoint,
      secret: _clientSecret,
      httpClient: httpClient,
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
          if (uri.queryParameters.containsKey('error')) {
            final error = uri.queryParameters['error'];
            final description = uri.queryParameters['error_description'];
            request.response
              ..statusCode = 400
              ..headers.set('Content-Type', 'text/html')
              ..write('<h3>Error: $error</h3><p>$description</p>');
            await request.response.close();
            await server.close();
            throw Exception('OAuth error: $error - $description');
          }

          final successHtml = await Resourceloader.load<String>(
            'auth_success.html',
            null,
          );
          request.response
            ..statusCode = 200
            ..headers.set('Content-Type', 'text/html')
            ..write(successHtml);
          await request.response.close();
          await server.close();

          final code = uri.queryParameters['code'];
          if (code == null) throw Exception('Authorization code not found');

          final client = await _exchangeCodeForToken(code);
          final username = await _getUsername(client);
          return {'client': client, 'username': username};
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

  Future<oauth2.Client> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      _tokenEndpoint,
      headers: {
        'Accept': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'redirect_uri': _redirectUri.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to exchange code for token: ${response.statusCode}',
      );
    }

    final params = Uri.splitQueryString(response.body);
    final accessToken = params['access_token'];
    final scope = params['scope'];

    if (accessToken == null) {
      throw Exception('Access token not found in response');
    }

    final credentials = oauth2.Credentials(
      accessToken,
      tokenEndpoint: _tokenEndpoint,
      scopes: scope?.split(',').toList() ?? _scopes,
    );

    return oauth2.Client(
      credentials,
      identifier: _clientId,
      secret: _clientSecret,
    );
  }

  Future<String> _getUsername(oauth2.Client client) async {
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
  }

  Future<Map<String, dynamic>> connectGitHub() async {
    try {
      return await _authenticate();
    } catch (e) {
      throw Exception('GitHub authentication failed: $e');
    }
  }

  Future<bool> validateGitHubToken(String accessToken) async {
    try {
      final credentials = oauth2.Credentials(
        accessToken,
        tokenEndpoint: _tokenEndpoint,
        scopes: _scopes,
      );
      final client = oauth2.Client(
        credentials,
        identifier: _clientId,
        secret: _clientSecret,
      );
      final resp = await client.get(Uri.parse('https://api.github.com/user'));
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
