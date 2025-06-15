import 'github_label.dart';
import 'github_user.dart';

class GithubIssue {
  final int id;
  final int number;
  final String title;
  final String? body;
  final String state;
  final GithubUser author;
  final List<GithubUser> assignees;
  final List<GithubLabel> labels;

  GithubIssue({
    required this.id,
    required this.number,
    required this.title,
    this.body,
    required this.state,
    required this.author,
    required this.assignees,
    required this.labels,
  });

  factory GithubIssue.fromJson(Map<String, dynamic> json) => GithubIssue(
    id: json['id'],
    number: json['number'],
    title: json['title'],
    body: json['body'],
    state: json['state'],
    author: GithubUser.fromJson(json['user']),
    assignees: (json['assignees'] as List)
        .map((a) => GithubUser.fromJson(a))
        .toList(),
    labels: (json['labels'] as List)
        .map((l) => GithubLabel.fromJson(l))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    if (body != null) 'body': body,
    'labels': labels.map((l) => l.name).toList(),
    'assignees': assignees.map((a) => a.login).toList(),
  };
}
