import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitnar/src/context/app_context.dart';
import 'package:gitnar/src/views/components/analytics_view.dart';
import 'package:gitnar/src/views/components/dashboard_view.dart';
import 'package:gitnar/src/views/components/issues_view.dart';
import 'package:gitnar/src/views/components/workflows_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  String? get _githubUsername => AppContext.instance.currentUser?.login;
  String? get _githubProfileImageUrl => _githubUsername != null
      ? 'https://github.com/$_githubUsername.png'
      : null;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF374151),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Disconnect',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to disconnect? This will clear all authentication data.',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppContext.instance.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ElevatedButton.icon(
          onPressed: onPressed ?? () {},
          icon: Icon(icon, size: 16, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(double.infinity, 36),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: const Border(
          right: BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_githubProfileImageUrl != null)
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(_githubProfileImageUrl!),
                        backgroundColor: const Color(0xFF374151),
                      )
                    else
                      const Icon(Icons.hub, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'GitNar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      'Connected',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
                if (_githubUsername != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      '@$_githubUsername',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Color(0xFF374151), height: 1),

          // Repository Links Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link, color: Color(0xFF9CA3AF), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Repository Links',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSidebarButton(
                  icon: Icons.add,
                  label: 'Add Repository Link',
                  color: const Color(0xFF10B981),
                  onPressed: () {
                    // Add repository link functionality
                  },
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF374151), height: 1),

          // Quick Actions Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flash_on, color: Color(0xFF9CA3AF), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSidebarButton(
                  icon: Icons.sync,
                  label: 'Sync All Issues',
                  color: const Color(0xFF8B5CF6),
                ),
                _buildSidebarButton(
                  icon: Icons.bar_chart,
                  label: 'Generate Report',
                  color: const Color(0xFF3B82F6),
                ),
                _buildSidebarButton(
                  icon: Icons.auto_fix_high,
                  label: 'Auto-Link Issues',
                  color: const Color(0xFF10B981),
                ),
                _buildSidebarButton(
                  icon: Icons.close_fullscreen,
                  label: 'Bulk Close Issues',
                  color: const Color(0xFFEF4444),
                ),
                _buildSidebarButton(
                  icon: Icons.download,
                  label: 'Export Data',
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnect,
                icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 16),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      color: const Color(0xFF1F2937),
      child: Row(
        children: [
          Expanded(child: _buildTopTabBar()),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF9CA3AF)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF9CA3AF)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTopTabBar() {
    return Row(
      children: [
        _buildTab('Dashboard', 0, Icons.dashboard_outlined),
        _buildTab('Workflows', 1, Icons.settings_outlined),
        _buildTab('Issues', 2, Icons.bug_report_outlined),
        _buildTab('Analytics', 3, Icons.analytics_outlined),
      ],
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const WorkflowsView();
      case 2:
        return const IssuesView();
      case 3:
        return const AnalyticsView();
      default:
        return const DashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF1E3A8A), Color(0xFF1F2937)],
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Container(
                      color: const Color(0xFF111827),
                      child: _getCurrentView(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
