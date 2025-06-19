import 'package:flutter/material.dart';

enum ToastMode { success, info, warning, error }

class Toast {
  static void success(
    BuildContext context,
    String message, {
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(context, message, ToastMode.success, onClose, duration);
  }

  static void info(
    BuildContext context,
    String message, {
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(context, message, ToastMode.info, onClose, duration);
  }

  static void warning(
    BuildContext context,
    String message, {
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(context, message, ToastMode.warning, onClose, duration);
  }

  static void error(
    BuildContext context,
    String message, {
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 5),
  }) {
    _showToast(context, message, ToastMode.error, onClose, duration);
  }

  static void _showToast(
    BuildContext context,
    String message,
    ToastMode mode,
    VoidCallback? onClose,
    Duration duration,
  ) {
    final overlay = Overlay.of(context);

    final key = GlobalKey<_ToastWidgetState>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) {
        return ToastWidget(
          key: key,
          message: message,
          mode: mode,
          onClose: () async {
            await key.currentState?.animateOut();
            if (entry.mounted) entry.remove();
            onClose?.call();
          },
        );
      },
    );

    overlay.insert(entry);

    // Auto‐dismiss after [duration]
    Future.delayed(duration, () async {
      if (!entry.mounted) return;
      await key.currentState?.animateOut();
      if (entry.mounted) entry.remove();
      onClose?.call();
    });
  }
}

class ToastWidget extends StatefulWidget {
  final String message;
  final ToastMode mode;
  final VoidCallback onClose;

  const ToastWidget({
    super.key,
    required this.message,
    required this.mode,
    required this.onClose,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animate in
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Called by the Toast helper to animate out before removal
  Future<void> animateOut() async {
    if (mounted) {
      await _controller.reverse();
    }
  }

  Color _getBackgroundColor() {
    switch (widget.mode) {
      case ToastMode.success:
        return const Color(0xFF28A745);
      case ToastMode.info:
        return const Color(0xFF17A2B8);
      case ToastMode.warning:
        return const Color(0xFFFFC107);
      case ToastMode.error:
        return const Color(0xFFDC3545);
    }
  }

  Color _getTextColor() {
    switch (widget.mode) {
      case ToastMode.warning:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  IconData _getIcon() {
    switch (widget.mode) {
      case ToastMode.success:
        return Icons.check_circle;
      case ToastMode.info:
        return Icons.info;
      case ToastMode.warning:
        return Icons.warning;
      case ToastMode.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Icon(_getIcon(), color: _getTextColor(), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.close,
                        color: _getTextColor(),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
