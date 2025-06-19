import 'dart:convert';
import 'package:gitnar/src/models/repository_link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gitnar/src/models/github/github_user.dart';
import 'package:gitnar/src/models/user_security.dart';

class AppContext {
  static AppContext? _instance;

  AppContext._();

  static AppContext get instance => _instance ??= AppContext._();

  GithubUser? currentUser;
  UserSecurity? security;
  List<RepositoryLink> repositoryLinks = [];

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

    if (repositoryLinks.isNotEmpty) {
      final linksJson = repositoryLinks.map((link) => link.toJson()).toList();
      prefs.setString('repositoryLinks', jsonEncode(linksJson));
    } else {
      prefs.remove('repositoryLinks');
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

    final linksJson = prefs.getString('repositoryLinks');
    if (linksJson != null) {
      final links = jsonDecode(linksJson);
      repositoryLinks = links
          .map((linkJson) => RepositoryLink.fromJson(linkJson))
          .toList();
    }
  }

  Future<void> clear() async {
    currentUser = null;
    security = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('security');
    await prefs.remove('currentUser');
    await prefs.remove('repositoryLinks');
  }

  Future<void> addRepositoryLink(RepositoryLink link) async {
    if (!repositoryLinks.any((existingLink) => existingLink.id == link.id)) {
      repositoryLinks.add(link);
      await save();
    }
  }

  Future<void> removeRepositoryLink(String linkId) async {
    repositoryLinks.removeWhere((link) => link.id == linkId);
    await save();
  }

  RepositoryLink? getRepositoryLink(String linkId) {
    try {
      return repositoryLinks.firstWhere((link) => link.id == linkId);
    } catch (e) {
      return null;
    }
  }

  bool isRepositoryLinked(String repositoryFullName, String sonarProjectKey) {
    return repositoryLinks.any(
      (link) =>
          link.repositoryFullName == repositoryFullName &&
          link.sonarProjectKey == sonarProjectKey,
    );
  }

  List<RepositoryLink> getLinksForRepository(String repositoryFullName) {
    return repositoryLinks
        .where((link) => link.repositoryFullName == repositoryFullName)
        .toList();
  }

  List<RepositoryLink> getLinksForSonarProject(String sonarProjectKey) {
    return repositoryLinks
        .where((link) => link.sonarProjectKey == sonarProjectKey)
        .toList();
  }

  bool get isFullyConnected =>
      security != null &&
      security!.githubAccessToken.isNotEmpty &&
      security!.sonarToken.isNotEmpty;
}
