import 'github_user.dart';

class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final GithubUser owner;
  final bool isPrivate;
  final String htmlUrl;
  final String? description;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final int openIssuesCount;
  final String? language;
  final int size; // Repository size in KB
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pushedAt;
  final bool hasIssues;
  final bool hasProjects;
  final bool hasWiki;
  final bool hasPages;
  final bool hasDownloads;
  final bool archived;
  final bool disabled;
  final String? license;
  final List<String> topics;

  GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.isPrivate,
    required this.htmlUrl,
    this.description,
    required this.stargazersCount,
    required this.forksCount,
    required this.watchersCount,
    required this.openIssuesCount,
    this.language,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
    required this.hasIssues,
    required this.hasProjects,
    required this.hasWiki,
    required this.hasPages,
    required this.hasDownloads,
    required this.archived,
    required this.disabled,
    this.license,
    required this.topics,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) => GithubRepo(
    id: json['id'],
    name: json['name'],
    fullName: json['full_name'],
    owner: GithubUser.fromJson(json['owner']),
    isPrivate: json['private'],
    htmlUrl: json['html_url'],
    description: json['description'],
    stargazersCount: json['stargazers_count'] ?? 0,
    forksCount: json['forks_count'] ?? 0,
    watchersCount: json['watchers_count'] ?? 0,
    openIssuesCount: json['open_issues_count'] ?? 0,
    language: json['language'],
    size: json['size'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    pushedAt: json['pushed_at'] != null
        ? DateTime.parse(json['pushed_at'])
        : null,
    hasIssues: json['has_issues'] ?? false,
    hasProjects: json['has_projects'] ?? false,
    hasWiki: json['has_wiki'] ?? false,
    hasPages: json['has_pages'] ?? false,
    hasDownloads: json['has_downloads'] ?? false,
    archived: json['archived'] ?? false,
    disabled: json['disabled'] ?? false,
    license: json['license']?['name'],
    topics: List<String>.from(json['topics'] ?? []),
  );

  // Convenience getters for formatted data
  String get formattedSize {
    if (size < 1024) return '${size}KB';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get formattedStars {
    if (stargazersCount < 1000) return stargazersCount.toString();
    if (stargazersCount < 1000000) {
      return '${(stargazersCount / 1000).toStringAsFixed(1)}k';
    }
    return '${(stargazersCount / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedForks {
    if (forksCount < 1000) return forksCount.toString();
    if (forksCount < 1000000) {
      return '${(forksCount / 1000).toStringAsFixed(1)}k';
    }
    return '${(forksCount / 1000000).toStringAsFixed(1)}M';
  }
}
