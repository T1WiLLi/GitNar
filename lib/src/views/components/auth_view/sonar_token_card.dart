import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SonarTokenCard extends StatelessWidget {
  final TextEditingController tokenController;
  final bool tokenSaved;
  final bool isSaving;
  final VoidCallback onSave;

  const SonarTokenCard({
    required this.tokenController,
    required this.tokenSaved,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.shield,
                color: Color(0xFFF97316),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SonarQube',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tokenController,
            obscureText: true,
            enabled: !tokenSaved,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.3,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF374151),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: tokenSaved
                  ? const FaIcon(
                      FontAwesomeIcons.circleCheck,
                      color: Color(0xFF16A34A),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (tokenSaved || isSaving) ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const FaIcon(FontAwesomeIcons.floppyDisk, size: 18),
            label: Text(
              isSaving
                  ? 'Saving...'
                  : tokenSaved
                  ? 'Token Saved'
                  : 'Save SonarQube Token',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: tokenSaved
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFF97316),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
