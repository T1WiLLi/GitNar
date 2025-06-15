import 'package:flutter/material.dart';

enum MessageType { error, warning, success, info }

class MessageWidget extends StatelessWidget {
  final String message;
  final MessageType type;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showIcon;
  final TextStyle? textStyle;

  const MessageWidget({
    required this.message,
    this.type = MessageType.info,
    this.icon,
    this.onDismiss,
    this.showCloseButton = false,
    this.padding,
    this.margin,
    this.showIcon = true,
    this.textStyle,
    super.key,
  });

  // Named constructors for convenience
  const MessageWidget.error({
    required String message,
    IconData? icon,
    VoidCallback? onDismiss,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool showIcon = true,
    TextStyle? textStyle,
    Key? key,
  }) : this(
         message: message,
         type: MessageType.error,
         icon: icon,
         onDismiss: onDismiss,
         showCloseButton: showCloseButton,
         padding: padding,
         margin: margin,
         showIcon: showIcon,
         textStyle: textStyle,
         key: key,
       );

  const MessageWidget.warning({
    required String message,
    IconData? icon,
    VoidCallback? onDismiss,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool showIcon = true,
    TextStyle? textStyle,
    Key? key,
  }) : this(
         message: message,
         type: MessageType.warning,
         icon: icon,
         onDismiss: onDismiss,
         showCloseButton: showCloseButton,
         padding: padding,
         margin: margin,
         showIcon: showIcon,
         textStyle: textStyle,
         key: key,
       );

  const MessageWidget.success({
    required String message,
    IconData? icon,
    VoidCallback? onDismiss,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool showIcon = true,
    TextStyle? textStyle,
    Key? key,
  }) : this(
         message: message,
         type: MessageType.success,
         icon: icon,
         onDismiss: onDismiss,
         showCloseButton: showCloseButton,
         padding: padding,
         margin: margin,
         showIcon: showIcon,
         textStyle: textStyle,
         key: key,
       );

  const MessageWidget.info({
    required String message,
    IconData? icon,
    VoidCallback? onDismiss,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool showIcon = true,
    TextStyle? textStyle,
    Key? key,
  }) : this(
         message: message,
         type: MessageType.info,
         icon: icon,
         onDismiss: onDismiss,
         showCloseButton: showCloseButton,
         padding: padding,
         margin: margin,
         showIcon: showIcon,
         textStyle: textStyle,
         key: key,
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        border: Border.all(color: colors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(icon ?? _getDefaultIcon(), color: colors.iconColor, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style:
                  textStyle ??
                  TextStyle(
                    color: colors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (showCloseButton || onDismiss != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.close,
                  color: colors.iconColor.withAlpha((0.7 * 255).toInt()),
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _MessageColors _getColors(ThemeData theme) {
    switch (type) {
      case MessageType.error:
        return _MessageColors(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF3F1A1A)
              : const Color(0xFFFEF2F2),
          borderColor: theme.brightness == Brightness.dark
              ? const Color(0xFF7F1D1D)
              : const Color(0xFFFCA5A5),
          textColor: theme.brightness == Brightness.dark
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFB91C1C),
          iconColor: theme.brightness == Brightness.dark
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFDC2626),
        );
      case MessageType.warning:
        return _MessageColors(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF3F2A0A)
              : const Color(0xFFFFFBEB),
          borderColor: theme.brightness == Brightness.dark
              ? const Color(0xFF92400E)
              : const Color(0xFFFDE68A),
          textColor: theme.brightness == Brightness.dark
              ? const Color(0xFFFDE68A)
              : const Color(0xFFB45309),
          iconColor: theme.brightness == Brightness.dark
              ? const Color(0xFFFDE68A)
              : const Color(0xFFD97706),
        );
      case MessageType.success:
        return _MessageColors(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF1A3F1A)
              : const Color(0xFFF0FDF4),
          borderColor: theme.brightness == Brightness.dark
              ? const Color(0xFF15803D)
              : const Color(0xFFA7F3D0),
          textColor: theme.brightness == Brightness.dark
              ? const Color(0xFFA7F3D0)
              : const Color(0xFF166534),
          iconColor: theme.brightness == Brightness.dark
              ? const Color(0xFFA7F3D0)
              : const Color(0xFF16A34A),
        );
      case MessageType.info:
        return _MessageColors(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF1A2F3F)
              : const Color(0xFFF0F9FF),
          borderColor: theme.brightness == Brightness.dark
              ? const Color(0xFF1D4ED8)
              : const Color(0xFF93C5FD),
          textColor: theme.brightness == Brightness.dark
              ? const Color(0xFF93C5FD)
              : const Color(0xFF1E40AF),
          iconColor: theme.brightness == Brightness.dark
              ? const Color(0xFF93C5FD)
              : const Color(0xFF2563EB),
        );
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.info:
        return Icons.info_outline;
    }
  }
}

class _MessageColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  const _MessageColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
}
