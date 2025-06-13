import 'package:flutter/material.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Text(
          'Analytics Placeholder',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
