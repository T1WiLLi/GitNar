import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:gitnar/src/models/github/github_repo.dart';
import 'package:gitnar/src/models/sonar/sonar_project.dart';

class RepositoryLink {
  final String id;
  final String repositoryName;
  final String repositoryOwner;
  final String sonarProjectKey;
  final String sonarProjectName;
  final DateTime createdAt;

  RepositoryLink({
    required this.id,
    required this.repositoryName,
    required this.repositoryOwner,
    required this.sonarProjectKey,
    required this.sonarProjectName,
    required this.createdAt,
  });

  factory RepositoryLink.fromRepoAndProject({
    required GithubRepo repository,
    required SonarProject sonarProject,
  }) {
    final id = _generateLinkId(repository.fullName, sonarProject.key);

    return RepositoryLink(
      id: id,
      repositoryName: repository.name,
      repositoryOwner: repository.owner.login,
      sonarProjectKey: sonarProject.key,
      sonarProjectName: sonarProject.name,
      createdAt: DateTime.now(),
    );
  }

  factory RepositoryLink.fromJson(Map<String, dynamic> json) {
    return RepositoryLink(
      id: json['id'] as String,
      repositoryName: json['repositoryName'] as String,
      repositoryOwner: json['repositoryOwner'] as String,
      sonarProjectKey: json['sonarProjectKey'] as String,
      sonarProjectName: json['sonarProjectName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String _generateLinkId(String repoFullName, String sonarProjectKey) {
    final input = '$repoFullName:$sonarProjectKey';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repositoryName': repositoryName,
      'repositoryOwner': repositoryOwner,
      'sonarProjectKey': sonarProjectKey,
      'sonarProjectName': sonarProjectName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get repositoryFullName => '$repositoryOwner/$repositoryName';
  String get displayName => '$repositoryName -> $sonarProjectName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepositoryLink && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RepositoryLink(id: $id, repo: $repositoryFullName, sonar: $sonarProjectKey)';
  }
}
