import 'package:gitnar/src/models/github/github_issue.dart';
import 'package:gitnar/src/models/github/github_label.dart';
import 'package:gitnar/src/models/github/github_project.dart';
import 'package:gitnar/src/models/github/github_user.dart';

class GithubRepo {
  final String name;
  final String description;
  final bool isPrivate;
  final List<GithubIssue> issues;
  final List<GithubLabel> labels;
  final List<GithubUser> collaborators;
  final List<GithubProject> projects;

  GithubRepo({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.issues,
    required this.labels,
    required this.collaborators,
    required this.projects,
  });
}
