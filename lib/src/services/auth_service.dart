import 'dart:io';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  // GitHub
  static final _ghAuthEndpoint = Uri.parse(
    'https://github.com/login/oauth/authorize',
  );
  static final _ghTokenEndpoint = Uri.parse(
    'https://github.com/login/oauth/access_token',
  );
  static const _ghClientId = '<GITHUB_CLIENT_ID>';
  static const _ghClientSecret = '<GITHUB_CLIENT_SECRET>';
  static final _ghRedirectUri = Uri.parse(
    'http://localhost:8080/github/callback',
  );
  static const _ghScopes = ['read:user'];

  // Sonar
  static final _sonarAuthEndpoint = Uri.parse(
    'https://sonarqube.yoursite/oauth/authorize',
  );
  static final _sonarTokenEndpoint = Uri.parse(
    'https://sonarqube.yoursite/oauth/token',
  );
  static const _sonarClientId = '<SONAR_CLIENT_ID>';
  static const _sonarClientSecret = '<SONAR_CLIENT_SECRET>';
  static final _sonarRedirectUri = Uri.parse(
    'http://localhost:8080/sonar/callback',
  );
  static const _sonarScopes = ['api'];

  Future<oauth2.Client> _authenticate(
    String clientId,
    String clientSecret,
    Uri authEndpoint,
    Uri tokenEndpoint,
    Uri redirectUri,
    List<String> scopes,
  ) async {
    final grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authEndpoint,
      tokenEndpoint,
      secret: clientSecret,
    );
    final authUrl = grant.getAuthorizationUrl(redirectUri, scopes: scopes);
    if (!await launchUrl(authUrl)) {
      throw 'Could not launch url: $authUrl';
    }

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      redirectUri.port,
    );
    final request = await server.first;
    final uri = request.uri;
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", "text/html")
      ..write("<h3>You may close this window.</h3>");
    await request.response.close();
    await server.close();

    return grant.handleAuthorizationResponse(uri.queryParameters);
  }

  Future<String> connectGitHub() async {
    final client = await _authenticate(
      _ghClientId,
      _ghClientSecret,
      _ghAuthEndpoint,
      _ghTokenEndpoint,
      _ghRedirectUri,
      _ghScopes,
    );
    final res = await client.get(Uri.parse('https://api.github.com/user'));
    final data = json.decode(res.body);
    return data['login'];
  }

  Future<String> connectSonar(String provider) async {
    final endpoint = provider == 'SonarCloud'
        ? Uri.parse('https://sonarcloud.io/api/oauth2/authorize')
        : _sonarAuthEndpoint;
    final client = await _authenticate(
      _sonarClientId,
      _sonarClientSecret,
      endpoint,
      _sonarTokenEndpoint,
      _sonarRedirectUri,
      _sonarScopes,
    );
    final res = await client.get(Uri.parse('\$provider/api/users/current'));
    final data = json.decode(res.body);
    return data['login'];
  }
}
