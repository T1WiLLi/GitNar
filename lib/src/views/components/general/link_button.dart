import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkButton extends StatelessWidget {
  final Uri _url = Uri.parse('https://flutter.dev');



  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _launchUrl,
      child: const Text('Aller sur Flutter.dev'),
    );
  }
}