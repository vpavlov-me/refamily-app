import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_platform.dart';
import '../theme/reluna_theme.dart';

/// Adaptive Card
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  
  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    final cardContent = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? RelunaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        boxShadow: isIOS
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isIOS
            ? Border.all(color: RelunaTheme.divider.withValues(alpha: 0.5))
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}

/// Adaptive List Tile
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  
  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing ?? (onTap != null 
            ? const Icon(CupertinoIcons.chevron_right, size: 18, color: RelunaTheme.textTertiary)
            : null),
        onTap: onTap,
        padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }
    
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}

/// Adaptive List Section (for grouped lists)
class AdaptiveListSection extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  
  const AdaptiveListSection({
    super.key,
    this.header,
    required this.children,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoListSection.insetGrouped(
        header: header != null ? Text(header!) : null,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: children,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              header!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RelunaTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        AdaptiveCard(
          padding: EdgeInsets.zero,
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isOdd) {
                return const Divider(height: 1, indent: 16);
              }
              return children[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}
