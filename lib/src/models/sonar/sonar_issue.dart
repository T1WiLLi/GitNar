class SonarIssue {
  final String key;
  final String rule;
  final String severity;
  final String status;
  final String component;
  final String project;
  final String message;
  final String? author;
  final String creationDate;
  final List<String>? tags;

  SonarIssue({
    required this.key,
    required this.rule,
    required this.severity,
    required this.status,
    required this.component,
    required this.project,
    required this.message,
    required this.creationDate,
    this.author,
    this.tags,
  });

  factory SonarIssue.fromJson(Map<String, dynamic> json) {
    return SonarIssue(
      key: json['key'] as String,
      rule: json['rule'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      component: json['component'] as String,
      project: json['project'] as String,
      message: json['message'] as String,
      creationDate: json['creationDate'] as String,
      author: json['author'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'rule': rule,
    'severity': severity,
    'status': status,
    'component': component,
    'project': project,
    'message': message,
    'creationDate': creationDate,
    if (author != null) 'author': author,
    if (tags != null) 'tags': tags,
  };
}
