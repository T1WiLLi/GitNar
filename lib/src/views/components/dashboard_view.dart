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
            padding: const EdgeInsets.all(16),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF374151), // stroke color
                width: 2, // stroke width
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected Repositories',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0AEC0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF374151), // stroke color
                width: 2, // stroke width
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Issues',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0AEC0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF374151), // stroke color
                width: 2, // stroke width
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
                transform: GradientRotation(145 * math.pi / 180),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolved Issues',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0AEC0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 403,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF374151), // stroke color
            width: 2, // stroke width
          ),
          gradient: LinearGradient(
            colors: [Color(0xFF3A4052), Color(0xFF2D3142)],
            transform: GradientRotation(145 * math.pi / 180),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,   
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.rotate_left, color: Colors.white, size: 24),
            SizedBox(width: 16),
            Text(
              'Recent activity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
