class LinkedRepository {
  final String id;
  final String githubRepo;
  final String sonarRepo;
  final DateTime linkedAt;

  LinkedRepository({
    required this.id,
    required this.githubRepo,
    required this.sonarRepo,
    required this.linkedAt,
  });
}
