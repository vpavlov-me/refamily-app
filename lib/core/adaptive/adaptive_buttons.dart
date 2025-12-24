import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_platform.dart';
import '../theme/reluna_theme.dart';

/// Adaptive Primary Button
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  
  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: isIOS
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon, 
                  size: 20,
                  color: isIOS 
                      ? (isOutlined ? RelunaTheme.accentColor : Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: isIOS 
                    ? TextStyle(
                        color: isOutlined ? RelunaTheme.accentColor : Colors.white,
                        fontWeight: FontWeight.w600,
                      )
                    : null,
              ),
            ],
          );
    
    if (isIOS) {
      return SizedBox(
        width: width,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          color: isOutlined ? null : RelunaTheme.accentColor,
          borderRadius: BorderRadius.circular(12),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }
    
    return SizedBox(
      width: width,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            )
          : FilledButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
    );
  }
}

/// Adaptive Text Button
class AdaptiveTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const AdaptiveTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: RelunaTheme.accentColor),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: const TextStyle(color: RelunaTheme.accentColor),
            ),
          ],
        ),
      );
    }
    
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
      label: Text(text),
    );
  }
}

/// Adaptive Icon Button
class AdaptiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon, size: size, color: color ?? RelunaTheme.accentColor),
      );
    }
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size),
      color: color,
    );
  }
}

/// Adaptive Floating Action Button
class AdaptiveFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  
  const AdaptiveFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return Container(
        decoration: BoxDecoration(
          color: RelunaTheme.accentColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: RelunaTheme.accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.all(16),
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
