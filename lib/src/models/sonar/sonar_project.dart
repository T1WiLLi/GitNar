class SonarProject {
  final String key;
  final String name;
  final String description;
  final String url;
  final int codeSmells;
  final int issues; // total issues (bugs + vulnerabilities + code smells)
  final double coverage; // in % (0–100)

  SonarProject({
    required this.key,
    required this.name,
    required this.description,
    required this.url,
    required this.codeSmells,
    required this.issues,
    required this.coverage,
  });

  factory SonarProject.fromJson(
    Map<String, dynamic> compJson,
    Map<String, dynamic> measuresJson,
  ) {
    final measures = measuresJson['component']['measures'] as List<dynamic>;
    int sm = 0, iss = 0;
    double cov = 0;
    for (var m in measures) {
      switch (m['metric']) {
        case 'code_smells':
          sm = int.tryParse(m['value']) ?? 0;
          break;
        case 'coverage':
          cov = double.tryParse(m['value'])?.toDouble() ?? 0.0;
          break;
        case 'issues':
          iss = int.tryParse(m['value']) ?? 0;
          break;
      }
    }

    return SonarProject(
      key: compJson['key'],
      name: compJson['name'] ?? '',
      description: compJson['description'] ?? '',
      url: compJson['url'] ?? '',
      codeSmells: sm,
      issues: iss,
      coverage: cov,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'description': description,
    'url': url,
    'code_smells': codeSmells,
    'issues': issues,
    'coverage': coverage,
  };
}
