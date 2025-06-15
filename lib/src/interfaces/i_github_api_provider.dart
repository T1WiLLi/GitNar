import '../models/github/github_user.dart';
import '../models/github/github_repo.dart';
import '../models/github/github_issue.dart';
import '../models/github/github_label.dart';
import '../models/github/github_project.dart';
import '../models/github/github_project_column.dart';

abstract class IGithubApiProvider {
  /// === User ===
  Future<GithubUser> getCurrentUser();

  /// === Repositories ===
  Future<List<GithubRepo>> getAllRepositories();

  /// === Issues ===
  Future<GithubIssue> createIssue({
    required String repoName,
    required String title,
    String? body,
    List<GithubLabel>? labels,
    List<String>? assignees,
  });

  Future<List<GithubIssue>> getIssues({required String repoName});

  /// === Labels ===
  Future<GithubLabel> createLabel({
    required String repoName,
    required GithubLabel label,
  });

  Future<List<GithubLabel>> getLabels({required String repoName});

  /// === Assignees ===
  Future<void> assignIssue({
    required String repoName,
    required int issueNumber,
    required List<String> assignees,
  });

  /// === Projects ===
  Future<List<GithubProject>> getProjects();
  Future<List<GithubProjectColumn>> getProjectColumns({required int projectId});

  Future<void> addCardToProjectColumn({
    required int columnId,
    required int issueId,
  });
}
