import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_platform.dart';
import '../theme/reluna_theme.dart';

/// Adaptive Dialog
class AdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: contentWidget ?? (content != null ? Text(content) : null),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: Text(cancelText),
              ),
            if (confirmText != null)
              CupertinoDialogAction(
                isDestructiveAction: isDestructive,
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onConfirm?.call();
                },
                child: Text(confirmText),
              ),
          ],
        ),
      );
    }
    
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: contentWidget ?? (content != null ? Text(content) : null),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          if (confirmText != null)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              style: isDestructive
                  ? FilledButton.styleFrom(backgroundColor: RelunaTheme.error)
                  : null,
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }
}

/// Adaptive Bottom Sheet
class AdaptiveBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: RelunaTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(child: child),
        ),
      );
    }
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }
}

/// Adaptive Action Sheet
class AdaptiveActionSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveAction> actions,
    AdaptiveAction? cancelAction,
  }) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: actions.map((action) => CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop(action.value);
              action.onPressed?.call();
            },
            isDestructiveAction: action.isDestructive,
            child: Text(action.title),
          )).toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    cancelAction.onPressed?.call();
                  },
                  child: Text(cancelAction.title),
                )
              : null,
        ),
      );
    }
    
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: const TextStyle(color: RelunaTheme.textSecondary),
                ),
              ),
            const SizedBox(height: 8),
            ...actions.map((action) => ListTile(
              title: Text(
                action.title,
                style: TextStyle(
                  color: action.isDestructive ? RelunaTheme.error : null,
                ),
              ),
              leading: action.icon != null ? Icon(action.icon) : null,
              onTap: () {
                Navigator.of(context).pop(action.value);
                action.onPressed?.call();
              },
            )),
            if (cancelAction != null) ...[
              const Divider(),
              ListTile(
                title: Text(cancelAction.title),
                onTap: () {
                  Navigator.of(context).pop();
                  cancelAction.onPressed?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdaptiveAction<T> {
  final String title;
  final IconData? icon;
  final T? value;
  final VoidCallback? onPressed;
  final bool isDestructive;
  
  const AdaptiveAction({
    required this.title,
    this.icon,
    this.value,
    this.onPressed,
    this.isDestructive = false,
  });
}

/// Adaptive Loading Indicator
class AdaptiveLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AdaptiveLoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoActivityIndicator(
        radius: size / 2,
        color: color,
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: color != null 
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );
  }
}

/// Adaptive Refresh Indicator
class AdaptiveRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  
  const AdaptiveRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    }
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
