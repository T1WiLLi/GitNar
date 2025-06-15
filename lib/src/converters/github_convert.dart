import 'package:gitnar/src/models/github/github_issue.dart';
import 'package:gitnar/src/models/github/github_label.dart';
import 'package:gitnar/src/models/github/github_project.dart';
import 'package:gitnar/src/models/github/github_project_column.dart';
import 'package:gitnar/src/models/github/github_repo.dart';
import 'package:gitnar/src/models/github/github_user.dart';

class GithubConvert {
  static GithubUser userFromJson(Map<String, dynamic> json) {
    return GithubUser(
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }

  static Map<String, dynamic> userToJson(GithubUser user) {
    return {'username': user.username, 'avatar_url': user.avatarUrl};
  }

  static GithubLabel labelFromJson(Map<String, dynamic> json) {
    return GithubLabel(
      name: json['name'],
      color: json['color'],
      description: json['descriptiopn'],
    );
  }

  static Map<String, dynamic> labelToJson(GithubLabel label) {
    return {
      'name': label.name,
      'color': label.color,
      'description': label.description,
    };
  }

  static GithubIssue issueFromJson(Map<String, dynamic> json) {
    final labels =
        (json['labels'] as List<dynamic>?)
            ?.map((l) => labelFromJson(l))
            .toList() ??
        [];
    final assignees =
        (json['assignees'] as List<dynamic>?)
            ?.map((a) => userFromJson(a))
            .toList() ??
        [];

    return GithubIssue(
      id: json['id'],
      number: json['number'],
      title: json['title'],
      body: json['body'],
      labels: labels,
      assignees: assignees,
      state: json['state'],
    );
  }

  static Map<String, dynamic> issueToJson(GithubIssue issue) {
    return {
      'id': issue.id,
      'number': issue.number,
      'title': issue.title,
      'body': issue.body,
      'labels': issue.labels.map(labelToJson).toList(),
      'assignees': issue.assignees.map(userToJson).toList(),
      'state': issue.state,
    };
  }

  static GithubProjectColumn columnFromJson(Map<String, dynamic> json) {
    return GithubProjectColumn(id: json['id'], name: json['name']);
  }

  static Map<String, dynamic> columnToJson(GithubProjectColumn column) {
    return {'id': column.id, 'name': column.name};
  }

  static GithubProject projectFromJson(Map<String, dynamic> json) {
    final columns =
        (json['columns'] as List<dynamic>?)
            ?.map((c) => columnFromJson(c))
            .toList() ??
        [];

    return GithubProject(
      id: json['id'],
      name: json['name'],
      body: json['body'],
      columns: columns,
    );
  }

  static Map<String, dynamic> projectToJson(GithubProject project) {
    return {
      'id': project.id,
      'name': project.name,
      'body': project.body,
      'columns': project.columns.map(columnToJson).toList(),
    };
  }

  static GithubRepo repoFromJson(Map<String, dynamic> json) {
    final issues =
        (json['issues'] as List<dynamic>?)
            ?.map((i) => issueFromJson(i))
            .toList() ??
        [];

    final labels =
        (json['labels'] as List<dynamic>?)
            ?.map((l) => labelFromJson(l))
            .toList() ??
        [];

    final collaborators =
        (json['collaborators'] as List<dynamic>?)
            ?.map((u) => userFromJson(u))
            .toList() ??
        [];

    final projects =
        (json['projects'] as List<dynamic>?)
            ?.map((p) => projectFromJson(p))
            .toList() ??
        [];

    return GithubRepo(
      name: json['name'],
      description: json['description'] ?? '',
      isPrivate: json['private'] ?? false,
      issues: issues,
      labels: labels,
      collaborators: collaborators,
      projects: projects,
    );
  }

  static Map<String, dynamic> repoToJson(GithubRepo repo) {
    return {
      'name': repo.name,
      'description': repo.description,
      'private': repo.isPrivate,
      'issues': repo.issues.map(issueToJson).toList(),
      'labels': repo.labels.map(labelToJson).toList(),
      'collaborators': repo.collaborators.map(userToJson).toList(),
      'projects': repo.projects.map(projectToJson).toList(),
    };
  }
}
