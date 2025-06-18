// Enhanced SonarProject model with comprehensive metrics
class SonarProject {
  final String key;
  final String name;
  final String description;
  final String url;
  final String organization;
  final String? qualifier; // TRK for projects, APP for applications
  final String visibility; // public or private
  final DateTime? lastAnalysisDate;
  final String? revision;

  // Quality metrics
  final int codeSmells;
  final int bugs;
  final int vulnerabilities;
  final int securityHotspots;
  final int issues; // total issues
  final double coverage; // in % (0–100)
  final double duplicatedLinesDensity;
  final int technicalDebt; // in minutes
  final String reliabilityRating; // A, B, C, D, E
  final String securityRating; // A, B, C, D, E
  final String maintainabilityRating; // A, B, C, D, E

  // Size metrics
  final int linesOfCode;
  final int statements;
  final int functions;
  final int classes;
  final int files;
  final int directories;

  SonarProject({
    required this.key,
    required this.name,
    required this.description,
    required this.url,
    required this.organization,
    this.qualifier,
    required this.visibility,
    this.lastAnalysisDate,
    this.revision,
    required this.codeSmells,
    required this.bugs,
    required this.vulnerabilities,
    required this.securityHotspots,
    required this.issues,
    required this.coverage,
    required this.duplicatedLinesDensity,
    required this.technicalDebt,
    required this.reliabilityRating,
    required this.securityRating,
    required this.maintainabilityRating,
    required this.linesOfCode,
    required this.statements,
    required this.functions,
    required this.classes,
    required this.files,
    required this.directories,
  });

  factory SonarProject.fromJson(
    Map<String, dynamic> compJson,
    Map<String, dynamic>? measuresJson,
  ) {
    // Initialize default values
    int codeSmells = 0,
        bugs = 0,
        vulnerabilities = 0,
        securityHotspots = 0,
        issues = 0;
    double coverage = 0.0, duplicatedLinesDensity = 0.0;
    int technicalDebt = 0,
        linesOfCode = 0,
        statements = 0,
        functions = 0,
        classes = 0,
        files = 0,
        directories = 0;
    String reliabilityRating = 'A',
        securityRating = 'A',
        maintainabilityRating = 'A';

    if (measuresJson != null && measuresJson['component'] != null) {
      final measures =
          measuresJson['component']['measures'] as List<dynamic>? ?? [];
      for (var m in measures) {
        final value = m['value']?.toString() ?? '0';
        switch (m['metric']) {
          case 'code_smells':
            codeSmells = int.tryParse(value) ?? 0;
            break;
          case 'bugs':
            bugs = int.tryParse(value) ?? 0;
            break;
          case 'vulnerabilities':
            vulnerabilities = int.tryParse(value) ?? 0;
            break;
          case 'security_hotspots':
            securityHotspots = int.tryParse(value) ?? 0;
            break;
          case 'violations':
          case 'issues':
            issues = int.tryParse(value) ?? 0;
            break;
          case 'coverage':
            coverage = double.tryParse(value) ?? 0.0;
            break;
          case 'duplicated_lines_density':
            duplicatedLinesDensity = double.tryParse(value) ?? 0.0;
            break;
          case 'sqale_index':
            technicalDebt = int.tryParse(value) ?? 0;
            break;
          case 'reliability_rating':
            reliabilityRating = value;
            break;
          case 'security_rating':
            securityRating = value;
            break;
          case 'sqale_rating':
          case 'maintainability_rating':
            maintainabilityRating = value;
            break;
          case 'ncloc':
            linesOfCode = int.tryParse(value) ?? 0;
            break;
          case 'statements':
            statements = int.tryParse(value) ?? 0;
            break;
          case 'functions':
            functions = int.tryParse(value) ?? 0;
            break;
          case 'classes':
            classes = int.tryParse(value) ?? 0;
            break;
          case 'files':
            files = int.tryParse(value) ?? 0;
            break;
          case 'directories':
            directories = int.tryParse(value) ?? 0;
            break;
        }
      }
    }

    return SonarProject(
      key: compJson['key'] ?? '',
      name: compJson['name'] ?? '',
      description: compJson['description'] ?? '',
      url: compJson['url'] ?? '',
      organization: compJson['organization'] ?? '',
      qualifier: compJson['qualifier'],
      visibility: compJson['visibility'] ?? 'public',
      lastAnalysisDate: compJson['lastAnalysisDate'] != null
          ? DateTime.tryParse(compJson['lastAnalysisDate'])
          : null,
      revision: compJson['revision'],
      codeSmells: codeSmells,
      bugs: bugs,
      vulnerabilities: vulnerabilities,
      securityHotspots: securityHotspots,
      issues: issues,
      coverage: coverage,
      duplicatedLinesDensity: duplicatedLinesDensity,
      technicalDebt: technicalDebt,
      reliabilityRating: reliabilityRating,
      securityRating: securityRating,
      maintainabilityRating: maintainabilityRating,
      linesOfCode: linesOfCode,
      statements: statements,
      functions: functions,
      classes: classes,
      files: files,
      directories: directories,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'description': description,
    'url': url,
    'organization': organization,
    'qualifier': qualifier,
    'visibility': visibility,
    'lastAnalysisDate': lastAnalysisDate?.toIso8601String(),
    'revision': revision,
    'code_smells': codeSmells,
    'bugs': bugs,
    'vulnerabilities': vulnerabilities,
    'security_hotspots': securityHotspots,
    'issues': issues,
    'coverage': coverage,
    'duplicated_lines_density': duplicatedLinesDensity,
    'technical_debt': technicalDebt,
    'reliability_rating': reliabilityRating,
    'security_rating': securityRating,
    'maintainability_rating': maintainabilityRating,
    'lines_of_code': linesOfCode,
    'statements': statements,
    'functions': functions,
    'classes': classes,
    'files': files,
    'directories': directories,
  };

  // Convenience getters
  String get displayName => '$name ($organization)';
  bool belongsToOrganization(String orgKey) => organization == orgKey;

  String get formattedTechnicalDebt {
    if (technicalDebt == 0) return '0min';
    if (technicalDebt < 60) return '${technicalDebt}min';
    if (technicalDebt < 1440) {
      return '${(technicalDebt / 60).toStringAsFixed(1)}h';
    }
    return '${(technicalDebt / 1440).toStringAsFixed(1)}d';
  }

  String get qualityGateStatus {
    if (bugs == 0 && vulnerabilities == 0 && codeSmells < 10 && coverage > 80) {
      return 'PASSED';
    }
    return 'FAILED';
  }

  bool get hasRecentAnalysis {
    if (lastAnalysisDate == null) return false;
    return DateTime.now().difference(lastAnalysisDate!).inDays < 30;
  }
}
