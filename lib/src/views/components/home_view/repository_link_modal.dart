import 'package:flutter/material.dart';
import 'package:gitnar/src/models/github/github_repo.dart';
import 'package:gitnar/src/models/sonar/sonar_project.dart';
import 'package:gitnar/src/providers/github_api_provider.dart';
import 'package:gitnar/src/providers/sonar_api_provider.dart';

class RepositoryLinkModal extends StatefulWidget {
  const RepositoryLinkModal({super.key});

  @override
  State<RepositoryLinkModal> createState() => _RepositoryLinkModalState();
}

class _RepositoryLinkModalState extends State<RepositoryLinkModal> {
  final githubProvider = GithubApiProvider();
  final sonarProvider = SonarApiProvider();

  int step = 1; // 1: Github Repos, 2: Sonar projects, 3: Confirm

  String searchQuery = "";
  GithubRepo? selectedRepo;
  SonarProject? selectedSonarProject;

  late Future<List<GithubRepo>> _githubReposFuture;
  late Future<List<SonarProject>> _sonarProjectsFuture;

  @override
  void initState() {
    super.initState();
    _githubReposFuture = githubProvider.getAllRepositories();
  }

  void onSelectRepo(GithubRepo repo) {
    setState(() {
      selectedRepo = repo;
      step = 2;
      _sonarProjectsFuture = sonarProvider.getProjects();
      searchQuery = "";
    });
  }

  void onSelectSonarProject(SonarProject project) {
    setState(() {
      selectedSonarProject = project;
      step = 3;
    });
  }

  void onConfirm() {
    Navigator.of(context).pop();
  }

  void onCancel() {
    Navigator.of(context).pop();
  }

  List<T> getFiltered<T>(List<T> items, String Function(T) extractor) {
    if (searchQuery.isEmpty) return items;
    return items
        .where(
          (item) =>
              extractor(item).toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (step == 1) {
      content = _buildFutureListStep<GithubRepo>(
        title: 'Select GitHub Repository',
        future: _githubReposFuture,
        itemTitle: (repo) => repo.name,
        onItemTap: onSelectRepo,
      );
    } else if (step == 2) {
      content = _buildFutureListStep<SonarProject>(
        title: 'Select Sonar Project',
        future: _sonarProjectsFuture,
        itemTitle: (proj) => proj.name,
        onItemTap: onSelectSonarProject,
      );
    } else {
      content = _buildConfirmationStep();
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureListStep<T>({
    required String title,
    required Future<List<T>> future,
    required String Function(T) itemTitle,
    required void Function(T) onItemTap,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final items = snapshot.data ?? [];
        final filtered = getFiltered(items, itemTitle);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(itemTitle(filtered[i])),
                    onTap: () => onItemTap(filtered[i]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Confirm Linking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text('Repository: ${selectedRepo?.name ?? ''}'),
        Text('Sonar Project: ${selectedSonarProject?.name ?? ''}'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Yes, Link Them'),
        ),
      ],
    );
  }
}
