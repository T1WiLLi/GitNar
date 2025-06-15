class GithubUser {
  final int id;
  final String login;
  final String avatarUrl;

  GithubUser({required this.id, required this.login, required this.avatarUrl});

  factory GithubUser.fromJson(Map<String, dynamic> json) => GithubUser(
    id: json['id'],
    login: json['login'],
    avatarUrl: json['avatar_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'login': login,
    'avatar_url': avatarUrl,
  };
}
