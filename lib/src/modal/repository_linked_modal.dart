import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitnar/src/models/linked_repository.dart';

class RepositoryLinkModal extends StatefulWidget {
  final Function(LinkedRepository) onRepositoryLinked;

  const RepositoryLinkModal({super.key, required this.onRepositoryLinked});

  @override
  State<RepositoryLinkModal> createState() => _RepositoryLinkModalState();
}

class _RepositoryLinkModalState extends State<RepositoryLinkModal> {
  int _currentStep = 0;
  String? _selectedGithubRepo;
  String? _selectedSonarRepo;
  final TextEditingController _githubSearchController = TextEditingController();
  final TextEditingController _sonarSearchController = TextEditingController();

  final List<String> _mockGithubRepos = [
    'flutter/flutter',
    'microsoft/vscode',
    'facebook/react',
    'tensorflow/tensorflow',
    'kubernetes/kubernetes',
    'nodejs/node',
    'angular/angular',
    'vuejs/vue',
  ];

  final List<String> _mockSonarRepos = [
    'flutter-project',
    'vscode-analysis',
    'react-frontend',
    'tensorflow-ml',
    'k8s-cluster',
    'node-backend',
    'angular-webapp',
    'vue-dashboard',
  ];

  List<String> _filteredGithubRepos = [];
  List<String> _filteredSonarRepos = [];

  @override
  void initState() {
    super.initState();
    _filteredGithubRepos = _mockGithubRepos;
    _filteredSonarRepos = _mockSonarRepos;
  }

  void _filterGithubRepos(String query) {
    setState(() {
      _filteredGithubRepos = _mockGithubRepos
          .where((repo) => repo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterSonarRepos(String query) {
    setState(() {
      _filteredSonarRepos = _mockSonarRepos
          .where((repo) => repo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _confirmLinking() {
    if (_selectedGithubRepo != null && _selectedSonarRepo != null) {
      final linkedRepo = LinkedRepository(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        githubRepo: _selectedGithubRepo!,
        sonarRepo: _selectedSonarRepo!,
        linkedAt: DateTime.now(),
      );
      widget.onRepositoryLinked(linkedRepo);
      Navigator.of(context).pop();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            _currentStep == 0
                ? FontAwesomeIcons.github
                : _currentStep == 1
                ? Icons.radar
                : Icons.link,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _currentStep == 0
                ? 'Select GitHub Repository'
                : _currentStep == 1
                ? 'Select Sonar Repository'
                : 'Confirm Repository Link',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepItem(0, 'GitHub', FontAwesomeIcons.github),
          _buildStepConnector(0),
          _buildStepItem(1, 'Sonar', Icons.radar),
          _buildStepConnector(1),
          _buildStepItem(2, 'Confirm', Icons.check),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : const Color(0xFF374151),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? const Color(0xFF10B981) : const Color(0xFF374151),
      ),
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: const Color(0xFF374151),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF10B981)),
          ),
        ),
      ),
    );
  }

  Widget _buildRepositoryList({
    required List<String> repositories,
    required String? selectedRepo,
    required Function(String) onSelect,
    required IconData icon,
  }) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: repositories.length,
        itemBuilder: (context, index) {
          final repo = repositories[index];
          final isSelected = selectedRepo == repo;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onSelect(repo),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981).withAlpha((0.1 * 255).toInt())
                      : const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF10B981))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        repo,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGithubStep() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _githubSearchController,
          hint: 'Search GitHub repositories...',
          onChanged: _filterGithubRepos,
        ),
        _buildRepositoryList(
          repositories: _filteredGithubRepos,
          selectedRepo: _selectedGithubRepo,
          onSelect: (repo) => setState(() => _selectedGithubRepo = repo),
          icon: FontAwesomeIcons.github,
        ),
      ],
    );
  }

  Widget _buildSonarStep() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _sonarSearchController,
          hint: 'Search Sonar repositories...',
          onChanged: _filterSonarRepos,
        ),
        _buildRepositoryList(
          repositories: _filteredSonarRepos,
          selectedRepo: _selectedSonarRepo,
          onSelect: (repo) => setState(() => _selectedSonarRepo = repo),
          icon: Icons.radar,
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.link, color: Color(0xFF10B981), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Ready to Link Repositories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The following repositories will be linked together:',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildRepoCard(
            icon: FontAwesomeIcons.github,
            label: 'GitHub Repository',
            name: _selectedGithubRepo ?? '',
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.sync_alt, color: Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 16),
          _buildRepoCard(
            icon: Icons.radar,
            label: 'Sonar Repository',
            name: _selectedSonarRepo ?? '',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoCard({
    required IconData icon,
    required String label,
    required String name,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9CA3AF),
              ),
            )
          else
            const SizedBox(),

          ElevatedButton.icon(
            onPressed: _currentStep == 0 && _selectedGithubRepo == null
                ? null
                : _currentStep == 1 && _selectedSonarRepo == null
                ? null
                : _currentStep == 2
                ? _confirmLinking
                : _nextStep,
            icon: Icon(
              _currentStep == 2 ? Icons.link : Icons.arrow_forward,
              size: 16,
            ),
            label: Text(_currentStep == 2 ? 'Link Repositories' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: _currentStep == 0
                  ? _buildGithubStep()
                  : _currentStep == 1
                  ? _buildSonarStep()
                  : _buildConfirmationStep(),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _githubSearchController.dispose();
    _sonarSearchController.dispose();
    super.dispose();
  }
}
