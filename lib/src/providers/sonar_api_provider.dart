import 'dart:convert';

import 'package:gitnar/src/context/app_context.dart';
import 'package:gitnar/src/interfaces/i_sonar_api_provider.dart';
import 'package:gitnar/src/models/sonar/sonar_comment.dart';
import 'package:gitnar/src/models/sonar/sonar_issue.dart';
import 'package:gitnar/src/models/sonar/sonar_organization.dart';
import 'package:gitnar/src/models/sonar/sonar_project.dart';
import 'package:http/http.dart' as http;

class SonarApiProvider implements ISonarApiProvider {
  final String _baseUrl = "https://sonarcloud.io";
  String? get _token => AppContext.instance.security?.sonarToken;

  Map<String, String> get _headers => {'Authorization': 'Bearer $_token'};

  static const List<String> _comprehensiveMetrics = [
    'code_smells',
    'bugs',
    'vulnerabilities',
    'security_hotspots',
    'violations',
    'coverage',
    'duplicated_lines_density',
    'sqale_index',
    'reliability_rating',
    'security_rating',
    'sqale_rating',
    'ncloc',
    'statements',
    'functions',
    'classes',
    'files',
    'directories',
  ];

  @override
  Future<bool> isTokenValid(String token) async {
    final url = Uri.parse('$_baseUrl/api/authentication/validate');
    final resp = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body)['valid'];
    }

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

  Future<List<String>> getUserOrganizations() async {
    final url = Uri.parse('$_baseUrl/api/organizations/search?member=true');
    final resp = await http.get(url, headers: _headers);

    print('Organizations response: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch user organizations: ${resp.body}');
    }

    final json = jsonDecode(resp.body);
    final orgs = json['organizations'] as List<dynamic>;
    return orgs.map((org) => org['key'] as String).toList();
  }

  Future<List<SonarOrganization>> getUserOrganizationsDetailed() async {
    final url = Uri.parse('$_baseUrl/api/organizations/search?member=true');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch user organizations: ${resp.body}');
    }

    final json = jsonDecode(resp.body);
    final orgs = json['organizations'] as List<dynamic>;
    return orgs.map((org) => SonarOrganization.fromJson(org)).toList();
  }

  @override
  Future<List<SonarProject>> getProjects({
    int pageSize = 100,
    int page = 1,
    String? organization,
    bool comprehensive = true,
  }) async {
    String? orgKey = organization;
    if (orgKey == null) {
      final orgs = await getUserOrganizations();
      if (orgs.isEmpty) {
        throw Exception(
          'No organizations found. Make sure your token has access to at least one organization.',
        );
      }
      orgKey = orgs.first;
    }

    final url = Uri.parse(
      '$_baseUrl/api/projects/search?organization=$orgKey&ps=$pageSize&p=$page',
    );
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch projects: ${resp.body}');
    }

    final compJson = jsonDecode(resp.body);
    final comps = compJson['components'] as List<dynamic>;

    return _buildProjectsWithMetrics(comps, comprehensive);
  }

  /// Enhanced getAllProjects with better error handling and logging
  Future<List<SonarProject>> getAllProjects({
    int pageSize = 100,
    int page = 1,
    bool comprehensive = true,
  }) async {
    final orgs = await getUserOrganizations();
    List<SonarProject> allProjects = [];

    print('Found ${orgs.length} organizations: ${orgs.join(", ")}');

    for (String org in orgs) {
      try {
        print('Fetching projects for organization: $org');
        final projects = await getProjects(
          pageSize: pageSize,
          page: page,
          organization: org,
          comprehensive: comprehensive,
        );
        print('Found ${projects.length} projects in $org');
        allProjects.addAll(projects);
      } catch (e) {
        print('Error fetching projects for $org: $e');
      }
    }

    print('Total projects found: ${allProjects.length}');
    return allProjects;
  }

  Future<List<SonarProject>> _buildProjectsWithMetrics(
    List<dynamic> components,
    bool comprehensive,
  ) async {
    List<SonarProject> projects = [];

    // Choose metrics based on comprehensive flag
    final metrics = comprehensive
        ? _comprehensiveMetrics
        : [
            'code_smells',
            'issues',
            'coverage',
            'bugs',
            'vulnerabilities',
            'security_hotspots',
            'sqale_index',
            'reliability_rating',
            'security_rating',
          ];

    for (var comp in components) {
      final key = comp['key'];

      final measuresUrl = Uri.parse(
        '$_baseUrl/api/measures/component?component=$key&metricKeys=${metrics.join(",")}',
      );
      final measuresResp = await http.get(measuresUrl, headers: _headers);

      if (measuresResp.statusCode == 200) {
        final measuresJson = jsonDecode(measuresResp.body);
        projects.add(SonarProject.fromJson(comp, measuresJson));
      } else {
        projects.add(SonarProject.fromJson(comp, null));
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
