import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Reluna Family App Theme with shadcn_ui
/// Accent color: #FB6428 (buttons, active states ONLY)
/// Font: PP Object Sans
class RelunaTheme {
  static const String fontFamily = 'PPObjectSans';
  
  static const Color accentColor = Color(0xFFFB6428);
  static const Color accentColorLight = Color(0xFFFFE4D9);
  
  // Neutral colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color background = backgroundLight;
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0x80121212); // 50% opacity
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0x0D121212); // 5% opacity
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Role colors
  static const Map<String, Color> roleColors = {
    'Founder': Color(0xFF8B5CF6),
    'Chair': Color(0xFF3B82F6),
    'CFO': Color(0xFF10B981),
    'Advisor': Color(0xFFF59E0B),
    'Next-Gen': Color(0xFFEC4899),
  };
  
  static Color getRoleColor(String role) {
    return roleColors[role] ?? textSecondary;
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return error;
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return textSecondary;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'voting':
        return accentColor;
      case 'pending':
        return warning;
      case 'approved':
        return success;
      case 'rejected':
        return error;
      default:
        return textSecondary;
    }
  }

  /// iOS Human Interface Guidelines Typography
  /// Based on Large (default) Dynamic Type sizes
  /// Font: PP Object Sans
  static ShadTextTheme _textTheme(Color foreground, Color mutedForeground) {
    return ShadTextTheme(
      // Large Title: 34pt Regular
      h1Large: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.2,
        letterSpacing: 0.37,
      ),
      // Title 1: 28pt Regular
      h1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.2,
        letterSpacing: 0.36,
      ),
      // Title 2: 22pt Regular  
      h2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.3,
        letterSpacing: 0.35,
      ),
      // Title 3: 20pt Regular
      h3: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.35,
        letterSpacing: 0.38,
      ),
      // Headline: 17pt Semibold
      h4: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
        letterSpacing: -0.43,
      ),
      // Body: 17pt Regular
      p: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
        letterSpacing: -0.43,
      ),
      // Blockquote: Body italic
      blockquote: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
        fontStyle: FontStyle.italic,
        height: 1.5,
        letterSpacing: -0.43,
      ),
      // Callout: 16pt Regular
      table: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
        letterSpacing: -0.31,
      ),
      // Body: 17pt for lists
      list: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
        letterSpacing: -0.43,
      ),
      // Lead: Title 3 style (20pt)
      lead: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
        height: 1.4,
        letterSpacing: 0.38,
      ),
      // Large: Headline (17pt Semibold)
      large: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
        letterSpacing: -0.43,
      ),
      // Subhead: 15pt Regular
      small: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
        letterSpacing: -0.23,
      ),
      // Footnote: 13pt Regular
      muted: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
        height: 1.5,
        letterSpacing: -0.08,
      ),
    );
  }

  /// iOS-compliant button sizes (minimum 44pt touch target)
  static ShadButtonSizesTheme _buttonSizesTheme() {
    return const ShadButtonSizesTheme(
      regular: ShadButtonSizeTheme(
        height: 50,  // iOS minimum 44pt + padding
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      sm: ShadButtonSizeTheme(
        height: 44,  // iOS minimum touch target
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      lg: ShadButtonSizeTheme(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      icon: ShadButtonSizeTheme(
        height: 44,  // iOS minimum touch target
        width: 44,
        padding: EdgeInsets.all(10),
      ),
    );
  }

  /// Light Theme Data with shadcn
  static ShadThemeData lightTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadOrangeColorScheme.light(
        primary: accentColor,
        primaryForeground: Colors.white,
        background: backgroundLight,
        foreground: textPrimary,
        card: surfaceLight,
        cardForeground: textPrimary,
        muted: const Color(0xFFF1F5F9),
        mutedForeground: textSecondary,
        destructive: error,
        destructiveForeground: Colors.white,
        border: divider,
        ring: accentColor,
      ),
      textTheme: _textTheme(textPrimary, textSecondary),
      buttonSizesTheme: _buttonSizesTheme(),
      radius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  /// Dark Theme Data with shadcn
  static ShadThemeData darkTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadOrangeColorScheme.dark(
        primary: accentColor,
        primaryForeground: Colors.white,
        background: backgroundDark,
        foreground: Colors.white,
        card: surfaceDark,
        cardForeground: Colors.white,
        muted: const Color(0xFF374151),
        mutedForeground: const Color(0xFF9CA3AF),
        destructive: error,
        destructiveForeground: Colors.white,
        border: const Color(0xFF374151),
        ring: accentColor,
      ),
      textTheme: _textTheme(Colors.white, const Color(0xFF9CA3AF)),
      buttonSizesTheme: _buttonSizesTheme(),
      radius: const BorderRadius.all(Radius.circular(12)),
    );
  }
}

/// Extension for quick access to theme colors
extension ThemeColorExtension on BuildContext {
  Color get accentColor => RelunaTheme.accentColor;
  Color get backgroundColor => RelunaTheme.backgroundLight;
  Color get surfaceColor => RelunaTheme.surfaceLight;
  Color get textPrimaryColor => RelunaTheme.textPrimary;
  Color get textSecondaryColor => RelunaTheme.textSecondary;
}
