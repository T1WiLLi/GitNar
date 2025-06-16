class SonarComment {
  final String key;
  final String issueKey;
  final String author;
  final String text;
  final String createdAt;

  SonarComment({
    required this.key,
    required this.issueKey,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  factory SonarComment.fromJson(Map<String, dynamic> json) {
    return SonarComment(
      key: json['key'] as String,
      issueKey: json['issue'] as String,
      author: json['author'] as String,
      text: json['text'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'issue': issueKey,
    'author': author,
    'text': text,
    'createdAt': createdAt,
  };
}
