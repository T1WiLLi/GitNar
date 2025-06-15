import 'github_user.dart';

class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final GithubUser owner;
  final bool isPrivate;
  final String htmlUrl;
  final String? description;

  GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.isPrivate,
    required this.htmlUrl,
    this.description,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) => GithubRepo(
    id: json['id'],
    name: json['name'],
    fullName: json['full_name'],
    owner: GithubUser.fromJson(json['owner']),
    isPrivate: json['private'],
    htmlUrl: json['html_url'],
    description: json['description'],
  );
}
