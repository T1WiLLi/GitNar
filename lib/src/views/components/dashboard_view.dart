import 'dart:math' as math;

import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        children: [
          Center(child: _buildInformationCard()),
          SizedBox(height: 16),
          Center(child: _buildRecentActivityCard()),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    return Expanded(
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
            transform: GradientRotation(145 * math.pi / 180),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
