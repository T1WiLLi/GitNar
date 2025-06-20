import 'package:flutter/material.dart';
import 'package:gitnar/src/context/app_context.dart';
import 'package:gitnar/src/models/repository_link.dart';

class RepositoryLinkList extends StatefulWidget {
  const RepositoryLinkList({super.key});

  @override
  State<RepositoryLinkList> createState() => _RepositoryLinkListState();
}

class _RepositoryLinkListState extends State<RepositoryLinkList> {
  List<RepositoryLink> repositoryLinks = [];

  @override
  void initState() {
    super.initState();
    _loadRepositoryLinks();
  }

  void _loadRepositoryLinks() {
    setState(() {
      repositoryLinks = AppContext.instance.repositoryLinks;
    });
  }

  Future<void> _removeLink(RepositoryLink link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF374151)),
          ),
          title: const Text(
            'Remove Repository Link',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove the link between ${link.repositoryFullName} and ${link.sonarProjectName}?',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9CA3AF),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AppContext.instance.removeRepositoryLink(link.id);
      _loadRepositoryLinks();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (repositoryLinks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 48, color: Color(0xFF6B7280)),
              Text(
                'No repository links yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: repositoryLinks.length,
      itemBuilder: (context, index) {
        final link = repositoryLinks[index];
        return RepositoryLinkCard(
          link: link,
          onRemove: () => _removeLink(link),
        );
      },
    );
  }
}

class RepositoryLinkCard extends StatelessWidget {
  final RepositoryLink link;
  final VoidCallback onRemove;

  const RepositoryLinkCard({
    super.key,
    required this.link,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
        top: 8.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            // Git icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.commit, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 6),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.repositoryFullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    link.sonarProjectName,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(link.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
