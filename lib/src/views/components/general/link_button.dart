import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkButton extends StatelessWidget {
  final Uri _url;
  final String _buttonText;

  const LinkButton({super.key, required String buttonText, required Uri url})
    : _buttonText = buttonText,
      _url = url;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _launchUrl,
      child: Text(
        _buttonText,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          ),
      ),
      
    );
  }
}
