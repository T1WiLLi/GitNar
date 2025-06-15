import 'package:gitnar/src/models/github/github_label.dart';
import 'package:gitnar/src/models/github/github_user.dart';

class GithubIssue {
  final int id;
  final int number;
  final String title;
  final String body;
  final List<GithubLabel> labels;
  final List<GithubUser> assignees;
  final String state;

  GithubIssue({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.labels,
    required this.assignees,
    required this.state,
  });
}
