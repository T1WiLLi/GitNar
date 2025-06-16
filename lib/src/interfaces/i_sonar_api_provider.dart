import 'package:gitnar/src/models/sonar/sonar_comment.dart';
import 'package:gitnar/src/models/sonar/sonar_issue.dart';
import 'package:gitnar/src/models/sonar/sonar_project.dart';

abstract class ISonarApiProvider {
  Future<bool> isTokenValid(String token);

  Future<String> getSonarVersion();

  Future<List<SonarProject>> getProjects({int pageSize = 100, int page = 1});

  Future<List<SonarIssue>> getIssues(String projectKey);

  Future<SonarIssue> getIssue(String issueKey);

  Future<List<SonarComment>> getIssueComments(String issueKey);

  Future<void> addComment(String issueKey, String comment);
}
