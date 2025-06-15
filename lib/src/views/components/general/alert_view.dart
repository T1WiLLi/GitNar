import 'package:flutter/material.dart';

// Simple Bootstrap-style alerts
class Alert extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  const Alert._({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });

  // Bootstrap-style alert functions
  static Widget success(String message) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFD4EDDA),
      textColor: const Color(0xFF155724),
      borderColor: const Color(0xFFC3E6CB),
      icon: Icons.check_circle,
    );
  }

  static Widget error(String message) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFF8D7DA),
      textColor: const Color(0xFF721C24),
      borderColor: const Color(0xFFF5C6CB),
      icon: Icons.error,
    );
  }

  static Widget warning(String message) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFFFF3CD),
      textColor: const Color(0xFF856404),
      borderColor: const Color(0xFFFFEEBA),
      icon: Icons.warning,
    );
  }

  static Widget info(String message) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFD1ECF1),
      textColor: const Color(0xFF0C5460),
      borderColor: const Color(0xFFBEE5EB),
      icon: Icons.info,
    );
  }

  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: widget.textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: widget.textColor, fontSize: 14),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVisible = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: widget.textColor.withAlpha((0.6 * 255).toInt()),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
