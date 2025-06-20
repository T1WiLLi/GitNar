import 'package:flutter/material.dart';
import 'package:gitnar/src/views/components/general/link_button.dart';

class InformationIconModal extends StatelessWidget {
  const InformationIconModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            // <<< make this scrollable >>>
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildContent()],
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gitnar is a powerful tool that helps you manage your Git and Sonar repositories with ease. To get started, follow these simple steps:',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 40),
          buildStepItem(
            step: 1,
            title: 'Select a Repository',
            description:
                'Go in the "Repositories" tab and select a repository to link.',
          ),
          const SizedBox(height: 32),
          buildStepItem(
            step: 2,
            title: 'Authorize Access',
            description:
                'Click “Authorize” on GitNar to grant access to your selected repository.',
          ),
          const SizedBox(height: 32),
          buildStepItem(
            step: 3,
            title: 'Complete Authorization',
            description:
                'Follow the prompts to complete the authorization process. This may involve logging into your Git account and confirming permissions.',
          ),
          const SizedBox(height: 32),
          buildStepItem(
            step: 4,
            title: 'Follow the Prompts',
            description:
                'Once authorized, follow any additional prompts to finalize the setup. This may include selecting specific branches or configuring settings.',
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(
                'For more information about GitNar, visit our repository:',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              LinkButton(
                buttonText: 'Click here',
                url: Uri.parse('https://github.com/T1WiLLi/GitNar.git'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerRight,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Close'),
          ),
        ],
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
          const Icon(Icons.help_outline, color: Color(0xFF10B981), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to use GitNar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStepItem({
    required int step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
