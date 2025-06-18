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

class _RepositoryLinkModalState extends State<RepositoryLinkModal>
    with TickerProviderStateMixin {
  final githubProvider = GithubApiProvider();
  final sonarProvider = SonarApiProvider();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  final PageController _pageController = PageController();

  String _searchQuery = '';
  GithubRepo? _selectedRepo;
  SonarProject? _selectedSonarProject;
  bool _isLoading = false;

  late Future<List<GithubRepo>> _githubReposFuture;
  Future<List<SonarProject>>? _sonarProjectsFuture;

  final List<String> _stepTitles = [
    'Select GitHub Repository',
    'Select Sonar Project',
    'Confirm Linking',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _githubReposFuture = githubProvider.getAllRepositories();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSelectRepo(GithubRepo repo) async {
    setState(() {
      _selectedRepo = repo;
      _isLoading = true;
      _searchQuery = '';
    });

    _sonarProjectsFuture = sonarProvider.getAllProjects();

    await _nextStep();

    setState(() {
      _isLoading = false;
    });
  }

  void _onSelectSonarProject(SonarProject project) {
    setState(() {
      _selectedSonarProject = project;
    });
    _nextStep();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _searchQuery = '';
      });

      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onConfirm() {
    // TODO: Implement actual linking logic
    Navigator.of(
      context,
    ).pop({'repository': _selectedRepo, 'sonarProject': _selectedSonarProject});
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  List<T> _getFilteredItems<T>(List<T> items, String Function(T) extractor) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where(
          (item) => extractor(
            item,
          ).toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildGitHubStep(),
                      _buildSonarStep(),
                      _buildConfirmationStep(),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF374151),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, color: Color(0xFF10B981), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Link Repository',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final _ = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF4B5563),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGitHubStep() {
    return _buildFutureStep<GithubRepo>(
      future: _githubReposFuture,
      emptyMessage: 'No repositories found',
      itemBuilder: (repo) => _buildRepoCard(repo),
      onItemTap: _onSelectRepo,
    );
  }

  Widget _buildSonarStep() {
    if (_sonarProjectsFuture == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            SizedBox(height: 16),
            Text(
              'No repository selected',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please go back and select a repository first.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildFutureStep<SonarProject>(
      future: _sonarProjectsFuture!,
      emptyMessage: 'No Sonar projects found',
      itemBuilder: (project) => _buildSonarProjectCard(project),
      onItemTap: _onSelectSonarProject,
    );
  }

  Widget _buildFutureStep<T>({
    required Future<List<T>> future,
    required String emptyMessage,
    required Widget Function(T) itemBuilder,
    required void Function(T) onItemTap,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
                SizedBox(height: 16),
                Text('Loading...', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading data',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        final filteredItems = _getFilteredItems(
          items,
          (item) =>
              item is GithubRepo ? item.name : (item as SonarProject).name,
        );

        return Column(
          children: [
            _buildSearchField(),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.inbox
                                : Icons.search_off,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? emptyMessage
                                : 'No results found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return itemBuilder(filteredItems[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4B5563)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4B5563)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF374151),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRepoCard(GithubRepo repo) {
    return Card(
      color: const Color(0xFF374151),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onSelectRepo(repo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
              if (repo.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  repo.description!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildStatChip(Icons.star, repo.formattedStars),
                  _buildStatChip(Icons.fork_right, repo.formattedForks),
                  _buildStatChip(Icons.bug_report, '${repo.openIssuesCount}'),
                  if (repo.language != null)
                    _buildStatChip(Icons.code, repo.language!),
                  _buildStatChip(Icons.storage, repo.formattedSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSonarProjectCard(SonarProject project) {
    return Card(
      color: const Color(0xFF374151),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onSelectSonarProject(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${project.key} • ${project.visibility.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildQualityBadge(
                    'Bugs',
                    project.bugs.toString(),
                    Colors.red,
                  ),
                  _buildQualityBadge(
                    'Vulnerabilities',
                    project.vulnerabilities.toString(),
                    Colors.orange,
                  ),
                  _buildQualityBadge(
                    'Code Smells',
                    project.codeSmells.toString(),
                    Colors.yellow,
                  ),
                  _buildQualityBadge(
                    'Coverage',
                    '${project.coverage.toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                  _buildQualityBadge(
                    'Duplicated',
                    '${project.duplicatedLinesDensity.toStringAsFixed(1)}%',
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4B5563),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).round()),
        border: Border.all(color: color.withAlpha((255 * 0.5).round())),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    if (_selectedRepo == null || _selectedSonarProject == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            SizedBox(height: 16),
            Text(
              'Missing selections',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please complete the previous steps first.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF10B981),
            size: 64,
          ),
          const SizedBox(height: 20), // Reduced from 24
          const Text(
            'Ready to Link',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          const Text(
            'You are about to link the following repository and Sonar project:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // Reduced from 24
          _buildSummaryCard(
            icon: Icons.folder,
            title: 'GitHub Repository',
            subtitle: _selectedRepo!.name,
            description: _selectedRepo!.description,
          ),
          const SizedBox(height: 12), // Reduced from 16
          _buildSummaryCard(
            icon: Icons.analytics,
            title: 'Sonar Project',
            subtitle: _selectedSonarProject!.displayName,
            description: _selectedSonarProject!.description,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
            )
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _onCancel,
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              if (_currentStep == 2)
                ElevatedButton.icon(
                  onPressed: _onConfirm,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Link Repository'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
