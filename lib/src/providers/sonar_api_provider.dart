import 'dart:convert';

import 'package:gitnar/src/context/app_context.dart';
import 'package:gitnar/src/interfaces/i_sonar_api_provider.dart';
import 'package:gitnar/src/models/sonar/sonar_comment.dart';
import 'package:gitnar/src/models/sonar/sonar_issue.dart';
import 'package:gitnar/src/models/sonar/sonar_project.dart';
import 'package:http/http.dart' as http;

class SonarApiProvider implements ISonarApiProvider {
  final String _baseUrl = "https://sonarcloud.io";
  String? get _token => AppContext.instance.security?.sonarToken;

  Map<String, String> get _headers => {'Authorization': 'Bearer $_token'};

  @override
  Future<bool> isTokenValid(String token) async {
    final url = Uri.parse('$_baseUrl/api/authentication/validate');
    final resp = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print(resp.body);

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body)['valid'];
    }

    // Invalid: 401
    return false;
  }

  @override
  Future<String> getSonarVersion() async {
    final url = Uri.parse('$_baseUrl/api/server/version');
    final resp = await http.get(url, headers: _headers);
    if (resp.statusCode == 200) {
      return resp.body;
    }
    throw Exception('Failed to fetch Sonar version');
  }

  @override
  Future<List<SonarProject>> getProjects({
    int pageSize = 100,
    int page = 1,
  }) async {
    final url = Uri.parse('$_baseUrl/api/projects/search?ps=$pageSize&p=$page');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch projects');
    }

    final compJson = jsonDecode(resp.body);
    final comps = compJson['components'] as List<dynamic>;

    List<SonarProject> projects = [];

    for (var comp in comps) {
      final key = comp['key'];

      final measuresUrl = Uri.parse(
        '$_baseUrl/api/measures/component?component=$key&metricKeys=code_smells,issues,coverage',
      );
      final measuresResp = await http.get(measuresUrl, headers: _headers);

      if (measuresResp.statusCode == 200) {
        final measuresJson = jsonDecode(measuresResp.body);
        projects.add(SonarProject.fromJson(comp, measuresJson));
      }
    }

    return projects;
  }

  @override
  Future<List<SonarIssue>> getIssues(String projectKey) async {
    final url = Uri.parse(
      '$_baseUrl/api/issues/search?componentKeys=$projectKey&ps=500',
    );
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch issues for project $projectKey');
    }

    final json = jsonDecode(resp.body);
    final issues = json['issues'] as List<dynamic>;
    return issues.map((e) => SonarIssue.fromJson(e)).toList();
  }

  @override
  Future<SonarIssue> getIssue(String issueKey) async {
    final url = Uri.parse('$_baseUrl/api/issues/search?issues=$issueKey');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch issue $issueKey');
    }

    final json = jsonDecode(resp.body);
    final issues = json['issues'] as List<dynamic>;

    if (issues.isEmpty) {
      throw Exception('Issue not found');
    }

    return SonarIssue.fromJson(issues.first);
  }

  @override
  Future<List<SonarComment>> getIssueComments(String issueKey) async {
    final url = Uri.parse('$_baseUrl/api/issues/comments?issue=$issueKey');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch comments for issue $issueKey');
    }

    final json = jsonDecode(resp.body);
    final comments = json['comments'] as List<dynamic>;
    return comments.map((e) => SonarComment.fromJson(e)).toList();
  }

  @override
  Future<void> addComment(String issueKey, String comment) async {
    final url = Uri.parse('$_baseUrl/api/issues/add_comment');
    final resp = await http.post(
      url,
      headers: {
        ..._headers,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'issue': issueKey, 'text': comment},
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to add comment to issue $issueKey');
    }
  }
}
