import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gitnar/src/models/github/github_user.dart';
import 'package:gitnar/src/models/user_security.dart';

class AppContext {
  static AppContext? _instance;

  AppContext._();

  static AppContext get instance => _instance ??= AppContext._();

  GithubUser? currentUser;
  UserSecurity? security;

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (security != null) {
      prefs.setString('security', jsonEncode(security!.toJson()));
    } else {
      prefs.remove('security');
    }

    if (currentUser != null) {
      prefs.setString('currentUser', jsonEncode(currentUser!.toJson()));
    } else {
      prefs.remove('currentUser');
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final securityJson = prefs.getString('security');
    if (securityJson != null) {
      security = UserSecurity.fromJson(jsonDecode(securityJson));
    }

    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      currentUser = GithubUser.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> clear() async {
    currentUser = null;
    security = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('security');
    await prefs.remove('currentUser');
  }

  bool get isFullyConnected =>
      security != null &&
      security!.githubAccessToken.isNotEmpty &&
      security!.sonarToken.isNotEmpty;
}
