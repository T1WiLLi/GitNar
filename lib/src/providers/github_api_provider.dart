import 'package:gitnar/src/interfaces/i_github_api_provider.dart';
import 'package:gitnar/src/models/github/github_issue.dart';
import 'package:gitnar/src/models/github/github_label.dart';
import 'package:gitnar/src/models/github/github_project.dart';
import 'package:gitnar/src/models/github/github_project_column.dart';
import 'package:gitnar/src/models/github/github_repo.dart';
import 'package:gitnar/src/models/github/github_user.dart';

class GithubApiProvider implements IGithubApiProvider {
  @override
  Future<void> addCardToProjectColumn({
    required int columnId,
    required int issueId,
  }) {
    // TODO: implement addCardToProjectColumn
    throw UnimplementedError();
  }

  @override
  Future<void> assignIssue({
    required String repoName,
    required int issueNumber,
    required List<String> assignees,
  }) {
    // TODO: implement assignIssue
    throw UnimplementedError();
  }

  @override
  Future<GithubIssue> createIssue({
    required String repoName,
    required String title,
    String? body,
    List<GithubLabel>? labels,
    List<String>? assignees,
  }) {
    // TODO: implement createIssue
    throw UnimplementedError();
  }

  @override
  Future<GithubLabel> createLabel({
    required String repoName,
    required GithubLabel label,
  }) {
    // TODO: implement createLabel
    throw UnimplementedError();
  }

  @override
  Future<List<GithubRepo>> getAllRepositories() {
    // TODO: implement getAllRepositories
    throw UnimplementedError();
  }

  @override
  Future<GithubUser> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<List<GithubIssue>> getIssues({required String repoName}) {
    // TODO: implement getIssues
    throw UnimplementedError();
  }

  @override
  Future<List<GithubLabel>> getLabels({required String repoName}) {
    // TODO: implement getLabels
    throw UnimplementedError();
  }

  @override
  Future<List<GithubProjectColumn>> getProjectColumns({
    required int projectId,
  }) {
    // TODO: implement getProjectColumns
    throw UnimplementedError();
  }

  @override
  Future<List<GithubProject>> getProjects() {
    // TODO: implement getProjects
    throw UnimplementedError();
  }
}
