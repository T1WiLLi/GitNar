import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // GitHub OAuth App credentials
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

  Future<oauth2.Client> _authenticate() async {
    // Create a custom HTTP client that accepts URL-encoded responses
    final httpClient = http.Client();

    final grant = oauth2.AuthorizationCodeGrant(
      _clientId,
      _authEndpoint,
      _tokenEndpoint,
      secret: _clientSecret,
      httpClient: httpClient,
    );

    final authUrl = grant.getAuthorizationUrl(_redirectUri, scopes: _scopes);

    print('Auth URL: $authUrl');

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
        print('Callback received: $uri');

        if (uri.path == '/github/callback') {
          // Check for errors first
          if (uri.queryParameters.containsKey('error')) {
            final error = uri.queryParameters['error'];
            final description = uri.queryParameters['error_description'];
            print('OAuth error: $error - $description');

            request.response
              ..statusCode = 400
              ..headers.set('Content-Type', 'text/html')
              ..write('<h3>Error: $error</h3><p>$description</p>');
            await request.response.close();
            await server.close();
            throw Exception('OAuth error: $error - $description');
          }

          request.response
            ..statusCode = 200
            ..headers.set('Content-Type', 'text/html')
            ..write('''
              <html>
                <body>
                  <h3>Authentication successful!</h3>
                  <p>You may close this window.</p>
                </body>
              </html>
            ''');
          await request.response.close();
          await server.close();

          // Handle the authorization response manually due to GitHub's format
          final code = uri.queryParameters['code'];
          if (code == null) {
            throw Exception('Authorization code not found');
          }

          // Exchange code for token manually
          final client = await _exchangeCodeForToken(code);
          return client;
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

    print('Token exchange response status: ${response.statusCode}');
    print('Token exchange response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to exchange code for token: ${response.statusCode}',
      );
    }

    // Parse the URL-encoded response
    final params = Uri.splitQueryString(response.body);
    print('Parsed params: $params');

    final accessToken = params['access_token'];
    final scope = params['scope'];

    if (accessToken == null) {
      throw Exception(
        'Access token not found in response. Available keys: ${params.keys.toList()}',
      );
    }

    print(
      'Successfully obtained access token: ${accessToken.substring(0, 10)}...',
    );

    // Create credentials manually
    final credentials = oauth2.Credentials(
      accessToken,
      tokenEndpoint: _tokenEndpoint,
      scopes:
          scope?.split('%3A').map((s) => Uri.decodeComponent(s)).toList() ??
          _scopes,
    );

    return oauth2.Client(credentials);
  }

  Future<String> connectGitHub() async {
    try {
      final client = await _authenticate();
      final resp = await client.get(Uri.parse('https://api.github.com/user'));

      print('GitHub API response status: ${resp.statusCode}');
      print('GitHub API response body: ${resp.body}');

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
      print('GitHub authentication error: $e');
      throw Exception('GitHub authentication failed: $e');
    }
  }
}
