import 'github_project_column.dart';

class GithubProject {
  final int id;
  final String name;
  final String? body;
  final List<GithubProjectColumn> columns;

  GithubProject({
    required this.id,
    required this.name,
    this.body,
    required this.columns,
  });
}
