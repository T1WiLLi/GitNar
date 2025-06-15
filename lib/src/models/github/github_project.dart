class GithubProject {
  final int id;
  final String name;
  final String body;
  final String state;
  final String url;

  GithubProject({
    required this.id,
    required this.name,
    required this.body,
    required this.state,
    required this.url,
  });

  factory GithubProject.fromJson(Map<String, dynamic> json) => GithubProject(
    id: json['id'],
    name: json['name'],
    body: json['body'] ?? '',
    state: json['state'],
    url: json['url'],
  );
}
