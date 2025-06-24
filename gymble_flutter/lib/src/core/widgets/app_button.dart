import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Button style based on type
    ButtonStyle getButtonStyle() {
      switch (type) {
        case AppButtonType.primary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          );
        case AppButtonType.secondary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
          );
        case AppButtonType.outline:
          return OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
          );
      }
    }

    // Button content
    Widget buttonContent() {
      if (isLoading) {
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      }

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      }

      return Text(text);
    }

    // Button widget based on type
    Widget buttonWidget() {
      switch (type) {
        case AppButtonType.primary:
        case AppButtonType.secondary:
          return ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: getButtonStyle(),
            child: buttonContent(),
          );
        case AppButtonType.outline:
          return OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: getButtonStyle(),
            child: buttonContent(),
          );
      }
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: buttonWidget(),
    );
  }
}