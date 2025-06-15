class UserSecurity {
  final String githubAccessToken;
  final String sonarToken;

  UserSecurity({required this.githubAccessToken, required this.sonarToken});

  factory UserSecurity.fromJson(Map<String, dynamic> json) {
    return UserSecurity(
      githubAccessToken: json['githubAccessToken'],
      sonarToken: json['sonarToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'githubAccessToken': githubAccessToken, 'sonarToken': sonarToken};
  }
}
