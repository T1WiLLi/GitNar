import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GithubConnectionCard extends StatelessWidget {
  final bool connected;
  final bool isConnecting;
  final String? username;
  final VoidCallback onConnect;

  const GithubConnectionCard({
    required this.connected,
    required this.isConnecting,
    required this.username,
    required this.onConnect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.github,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'GitHub',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (connected || isConnecting) ? null : onConnect,
            icon: isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : connected
                ? const FaIcon(
                    FontAwesomeIcons.circleCheck,
                    color: Color(0xFF16A34A),
                    size: 16,
                  )
                : const SizedBox.shrink(),
            label: Text(
              isConnecting
                  ? 'Connecting...'
                  : connected
                  ? 'Logged in as $username'
                  : 'Connect to GitHub',
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(const Color(0xFF2563EB)),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.white;
                }
                return Colors.white;
              }),
              minimumSize: WidgetStateProperty.all(const Size(300, 48)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
