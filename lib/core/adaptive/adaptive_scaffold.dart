import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_platform.dart';
import '../theme/reluna_theme.dart';

/// Adaptive Scaffold - CupertinoPageScaffold on iOS, Scaffold on Android
class AdaptiveScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool hasBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool largeTitle;
  final Widget? trailing;
  
  const AdaptiveScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.hasBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.largeTitle = false,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return _buildCupertinoScaffold(context);
    }
    return _buildMaterialScaffold(context);
  }
  
  Widget _buildCupertinoScaffold(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor ?? RelunaTheme.backgroundLight,
      navigationBar: title != null || titleWidget != null || hasBackButton
          ? CupertinoNavigationBar(
              backgroundColor: RelunaTheme.surfaceLight.withValues(alpha: 0.9),
              border: null,
              leading: hasBackButton
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                      child: const Icon(CupertinoIcons.back, color: RelunaTheme.accentColor),
                    )
                  : leading,
              middle: titleWidget ?? (title != null 
                  ? Text(title!, style: const TextStyle(fontWeight: FontWeight.w600))
                  : null),
              trailing: trailing ?? (actions != null && actions!.isNotEmpty 
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    )
                  : null),
            )
          : null,
      child: SafeArea(
        // Wrap in Material to provide Material context for TabBar and other Material widgets
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              body,
              if (floatingActionButton != null)
                Positioned(
                  right: 16,
                  bottom: bottomNavigationBar != null ? 80 : 16,
                  child: floatingActionButton!,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMaterialScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? RelunaTheme.backgroundLight,
      appBar: title != null || titleWidget != null || hasBackButton || leading != null
          ? AppBar(
              leading: hasBackButton
                  ? IconButton(
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : leading,
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Adaptive AppBar for custom cases
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool hasBackButton;
  final VoidCallback? onBackPressed;
  
  const AdaptiveAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.hasBackButton = false,
    this.onBackPressed,
  });
  
  @override
  Size get preferredSize => const Size.fromHeight(56);
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoNavigationBar(
        backgroundColor: RelunaTheme.surfaceLight.withValues(alpha: 0.9),
        border: null,
        leading: hasBackButton
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                child: const Icon(CupertinoIcons.back, color: RelunaTheme.accentColor),
              )
            : leading,
        middle: titleWidget ?? (title != null 
            ? Text(title!, style: const TextStyle(fontWeight: FontWeight.w600))
            : null),
        trailing: actions != null && actions!.isNotEmpty 
            ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
            : null,
      );
    }
    
    return AppBar(
      leading: hasBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            )
          : leading,
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
    );
  }
}
