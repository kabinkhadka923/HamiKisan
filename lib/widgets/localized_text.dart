import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';

/// A widget that automatically translates text based on the current language
class LocalizedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localization, child) {
        return Text(
          localization.translate(translationKey),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Extension method to make translation even easier
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return Provider.of<LocalizationProvider>(this, listen: false)
        .translate(key);
  }

  LocalizationProvider get localization =>
      Provider.of<LocalizationProvider>(this, listen: false);
}
