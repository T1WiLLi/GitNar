import 'package:flutter/material.dart';

// Simple Bootstrap-style alerts with fade animations
class Alert extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;
  final VoidCallback? onClose;
  final Duration animationDuration;

  const Alert._({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    this.onClose,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  // Bootstrap-style alert functions
  static Widget success(
    String message, {
    VoidCallback? onClose,
    Duration? animationDuration,
  }) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFD4EDDA),
      textColor: const Color(0xFF155724),
      borderColor: const Color(0xFFC3E6CB),
      icon: Icons.check_circle,
      onClose: onClose,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
    );
  }

  static Widget error(
    String message, {
    VoidCallback? onClose,
    Duration? animationDuration,
  }) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFF8D7DA),
      textColor: const Color(0xFF721C24),
      borderColor: const Color(0xFFF5C6CB),
      icon: Icons.error,
      onClose: onClose,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
    );
  }

  static Widget warning(
    String message, {
    VoidCallback? onClose,
    Duration? animationDuration,
  }) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFFFF3CD),
      textColor: const Color(0xFF856404),
      borderColor: const Color(0xFFFFEEBA),
      icon: Icons.warning,
      onClose: onClose,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
    );
  }

  static Widget info(
    String message, {
    VoidCallback? onClose,
    Duration? animationDuration,
  }) {
    return Alert._(
      message: message,
      backgroundColor: const Color(0xFFD1ECF1),
      textColor: const Color(0xFF0C5460),
      borderColor: const Color(0xFFBEE5EB),
      icon: Icons.info,
      onClose: onClose,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
    );
  }

  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start fade-in animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() async {
    if (_isClosing) return;

    setState(() {
      _isClosing = true;
    });

    // Start fade-out animation
    await _animationController.reverse();

    // Call onClose callback if provided
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * _fadeAnimation.value), // Subtle scale effect
            child: Container(
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
                      onTap: _handleClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: widget.textColor.withAlpha(
                            (0.6 * 255).toInt(),
                          ),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
