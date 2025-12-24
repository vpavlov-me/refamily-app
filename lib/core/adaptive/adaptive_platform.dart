import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

/// Platform detection helper
class AdaptivePlatform {
  static bool get isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
  
  static bool get isAndroid {
    try {
      return Platform.isAndroid;
    } catch (_) {
      return true; // Default to Material
    }
  }
  
  static bool isIOSByContext(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }
}

/// Adaptive widget that renders Cupertino on iOS, Material on Android
class AdaptiveWidget extends StatelessWidget {
  final Widget Function(BuildContext) ios;
  final Widget Function(BuildContext) android;
  
  const AdaptiveWidget({
    super.key,
    required this.ios,
    required this.android,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return ios(context);
    }
    return android(context);
  }
}
