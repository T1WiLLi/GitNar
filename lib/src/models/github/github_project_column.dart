class GithubProjectColumn {
  final int id;
  final String name;
  final String projectUrl;
  final String cardsUrl;

  GithubProjectColumn({
    required this.id,
    required this.name,
    required this.projectUrl,
    required this.cardsUrl,
  });

  factory GithubProjectColumn.fromJson(Map<String, dynamic> json) =>
      GithubProjectColumn(
        id: json['id'],
        name: json['name'],
        projectUrl: json['project_url'],
        cardsUrl: json['cards_url'],
      );
}
