import 'package:gitnar/src/models/github/github_user.dart';
import 'package:gitnar/src/models/user_security.dart';

class AppContext {
  static AppContext? _instance;

  AppContext._();

  static AppContext get instance => _instance ??= AppContext._();

  GithubUser? currentUser;
  UserSecurity? security;

  void clear() {
    currentUser = null;
    security = null;
  }
}
