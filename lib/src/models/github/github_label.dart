class GithubLabel {
  final int id;
  final String name;
  final String? description;
  final String color;
  final String url;

  GithubLabel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.url,
  });

  factory GithubLabel.fromJson(Map<String, dynamic> json) => GithubLabel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    color: json['color'],
    url: json['url'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'color': color,
  };
}
