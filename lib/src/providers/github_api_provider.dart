import 'dart:convert';
import 'package:gitnar/src/context/app_context.dart';
import 'package:http/http.dart' as http;

import 'package:gitnar/src/interfaces/i_github_api_provider.dart';
import 'package:gitnar/src/models/github/github_issue.dart';
import 'package:gitnar/src/models/github/github_label.dart';
import 'package:gitnar/src/models/github/github_project.dart';
import 'package:gitnar/src/models/github/github_project_column.dart';
import 'package:gitnar/src/models/github/github_repo.dart';
import 'package:gitnar/src/models/github/github_user.dart';

class GithubApiProvider implements IGithubApiProvider {
  static const String _baseUrl = 'https://api.github.com';

  String get _token {
    final token = AppContext.instance.security?.githubAccessToken;
    if (token == null || token.isEmpty) {
      throw Exception('GitHub token is not available in AppContext');
    }
    return token;
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Accept': 'application/vnd.github+json',
  };

  @override
  Future<GithubUser> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return GithubUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch current user: ${response.body}');
    }
  }

  @override
  Future<List<GithubRepo>> getAllRepositories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/repos'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List reposJson = jsonDecode(response.body);
      return reposJson.map((e) => GithubRepo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch repositories: ${response.body}');
    }
  }

  @override
  Future<List<GithubIssue>> getIssues({required String repoName}) async {
    final user = await getCurrentUser();
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/${user.login}/$repoName/issues'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List issuesJson = jsonDecode(response.body);
      return issuesJson.map((e) => GithubIssue.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch issues: ${response.body}');
    }
  }

  @override
  Future<GithubIssue> createIssue({
    required String repoName,
    required String title,
    String? body,
    List<GithubLabel>? labels,
    List<String>? assignees,
  }) async {
    final user = await getCurrentUser();
    final requestBody = {
      'title': title,
      if (body != null) 'body': body,
      if (labels != null) 'labels': labels.map((e) => e.name).toList(),
      if (assignees != null) 'assignees': assignees,
    };
    final response = await http.post(
      Uri.parse('$_baseUrl/repos/${user.login}/$repoName/issues'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 201) {
      return GithubIssue.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create issue: ${response.body}');
    }
  }

  @override
  Future<void> assignIssue({
    required String repoName,
    required int issueNumber,
    required List<String> assignees,
  }) async {
    final user = await getCurrentUser();
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/repos/${user.login}/$repoName/issues/$issueNumber/assignees',
      ),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'assignees': assignees}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign issue: ${response.body}');
    }
  }

  @override
  Future<GithubLabel> createLabel({
    required String repoName,
    required GithubLabel label,
  }) async {
    final user = await getCurrentUser();
    final response = await http.post(
      Uri.parse('$_baseUrl/repos/${user.login}/$repoName/labels'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(label.toJson()),
    );
    if (response.statusCode == 201) {
      return GithubLabel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create label: ${response.body}');
    }
  }

  @override
  Future<List<GithubLabel>> getLabels({required String repoName}) async {
    final user = await getCurrentUser();
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/${user.login}/$repoName/labels'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List labelsJson = jsonDecode(response.body);
      return labelsJson.map((e) => GithubLabel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch labels: ${response.body}');
    }
  }

  @override
  Future<List<GithubProject>> getProjects() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/projects'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List projectsJson = jsonDecode(response.body);
      return projectsJson.map((e) => GithubProject.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch projects: ${response.body}');
    }
  }

  @override
  Future<List<GithubProjectColumn>> getProjectColumns({
    required int projectId,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projects/$projectId/columns'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List columnsJson = jsonDecode(response.body);
      return columnsJson.map((e) => GithubProjectColumn.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch project columns: ${response.body}');
    }
  }

  @override
  Future<void> addCardToProjectColumn({
    required int columnId,
    required int issueId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/projects/columns/$columnId/cards'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'content_id': issueId, 'content_type': 'Issue'}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add card to column: ${response.body}');
    }
  }
}
