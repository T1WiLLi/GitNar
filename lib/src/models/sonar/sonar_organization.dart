class SonarOrganization {
  final String key;
  final String name;
  final String description;
  final String url;
  final String avatar;
  final Map<String, dynamic> alm;
  final Map<String, bool> actions;
  final String subscription;
  final bool isPersonal;

  SonarOrganization({
    required this.key,
    required this.name,
    required this.description,
    required this.url,
    required this.avatar,
    required this.alm,
    required this.actions,
    required this.subscription,
    required this.isPersonal,
  });

  factory SonarOrganization.fromJson(Map<String, dynamic> json) {
    return SonarOrganization(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      avatar: json['avatar'] ?? '',
      alm: Map<String, dynamic>.from(json['alm'] ?? {}),
      actions: Map<String, bool>.from(json['actions'] ?? {}),
      subscription: json['subscription'] ?? 'FREE',
      isPersonal: json['alm']?['personal'] ?? false,
    );
  }

  bool get canAdmin => actions['admin'] ?? false;
  bool get canDelete => actions['delete'] ?? false;
  bool get canProvision => actions['provision'] ?? false;
  String get almProvider => alm['key'] ?? 'unknown';
}
