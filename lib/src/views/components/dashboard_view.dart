import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Text(
          'Dashboard Placeholder',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
