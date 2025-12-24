import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_platform.dart';
import '../theme/reluna_theme.dart';

/// Adaptive Text Field
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textPrimary,
                ),
              ),
            ),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            prefix: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: prefix,
                  )
                : null,
            suffix: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            enabled: enabled,
            maxLines: maxLines,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: RelunaTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null 
                    ? RelunaTheme.error 
                    : RelunaTheme.divider,
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: RelunaTheme.error,
                ),
              ),
            ),
        ],
      );
    }
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: prefix,
        suffixIcon: suffix,
        errorText: errorText,
      ),
    );
  }
}

/// Adaptive Search Field
class AdaptiveSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  
  const AdaptiveSearchField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOSByContext(context)) {
      return CupertinoSearchTextField(
        controller: controller,
        placeholder: placeholder ?? 'Search',
        onChanged: onChanged,
        onSuffixTap: onClear,
      );
    }
    
    return SearchBar(
      controller: controller,
      hintText: placeholder ?? 'Search',
      onChanged: onChanged,
      leading: const Icon(Icons.search),
      trailing: controller?.text.isNotEmpty == true
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              ),
            ]
          : null,
    );
  }
}
