import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/constant/app_constant.dart';
import 'package:belwork/utils/languages/app_translator.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppText extends ConsumerStatefulWidget {
  const AppText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.textScaleFactor = 0.9,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.decoration,
    this.isDynamic = true,
    this.translate = true,
    this.decorationColor,
    this.fontFamily,
    this.style,
  });

  final String text;
  final double? fontSize;
  final double textScaleFactor;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final bool isDynamic;
  final bool translate;
  final String? fontFamily;
  final TextStyle? style;

  @override
  ConsumerState<AppText> createState() => _AppTextState();
}

class _AppTextState extends ConsumerState<AppText> {
  String? _translatedText;
  String? _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _selectedLanguage = ref.read(languageProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateText();
    });
  }

  @override
  void didUpdateWidget(covariant AppText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text ||
        oldWidget.translate != widget.translate ||
        oldWidget.isDynamic != widget.isDynamic) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    if (!widget.translate) {
      setState(() {
        _translatedText = widget.text;
        _isLoading = false;
      });
      return;
    }

    final language = ref.read(languageProvider);

    if (widget.isDynamic == false) {
      final languageMap = AppTranslator.localTrans(
        widget.text,
        language,
      );

      if (!mounted) return;

      setState(() {
        _selectedLanguage = language;
        _translatedText = languageMap ?? widget.text;
        _isLoading = false;
      });

      return;
    }

    setState(() {
      _selectedLanguage = language;
      _isLoading = true;
    });

    try {
      final value = await AppTranslator.translate(
        widget.text,
        language,
      );

      if (!mounted) return;

      setState(() {
        _translatedText = value;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _translatedText = widget.text;
        _isLoading = false;
      });
    }
  }

  TextStyle _textStyle(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall?.copyWith(
      height: widget.height,
      fontSize: widget.fontSize,
      color: widget.color ?? AppColors.instance.textColor,
      fontWeight: widget.fontWeight,
      fontFamily:
      widget.fontFamily ?? AppConstant.instance.font,
      decoration: widget.decoration,
      decorationColor: widget.decorationColor,
    ) ??
        const TextStyle();
  }

  Widget _buildText(String value) {
    return Text(
      value,
      maxLines: widget.maxLines,
      overflow: widget.overflow ?? TextOverflow.ellipsis,
      textAlign: widget.textAlign,
      style: widget.style ?? _textStyle(context),
      textScaler: TextScaler.linear(widget.textScaleFactor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    // Language change হলে translation আবার fetch করবে
    if (_selectedLanguage != currentLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _translateText();
        }
      });
    }

    if (_isLoading) {
      return Skeletonizer(
        enabled: true,
        child: _buildText(widget.text),
      );
    }

    return _buildText(
      _translatedText ?? widget.text,
    );
  }
}
// import 'package:belwork/constant/app_colors.dart';


// import 'package:belwork/constant/app_constant.dart';
// import 'package:belwork/utils/languages/app_translator.dart';
// import 'package:belwork/utils/languages/language_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';
//
// class AppText extends ConsumerWidget {
//   const AppText({
//     super.key,
//     required this.text,
//     this.fontSize = 16,
//     this.textScaleFactor = 0.9,
//     this.color,
//     this.fontWeight = FontWeight.w400,
//     this.maxLines,
//     this.overflow,
//     this.textAlign,
//     this.height,
//     this.decoration,
//     this.isDynamic = true,
//     this.translate = true,
//     this.decorationColor,
//     this.fontFamily,
//     this.style,
//   });
//
//   final String text;
//   final double? fontSize;
//   final double textScaleFactor;
//   final Color? color;
//   final FontWeight? fontWeight;
//   final int? maxLines;
//   final TextOverflow? overflow;
//   final TextAlign? textAlign;
//   final double? height;
//   final TextDecoration? decoration;
//   final Color? decorationColor;
//   final bool isDynamic;
//   final bool translate;
//   final String? fontFamily;
//   final TextStyle? style;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     var textStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
//       height: height,
//       fontSize: fontSize,
//       color: color ?? AppColors.instance.textColor,
//       fontWeight: fontWeight,
//       fontFamily: fontFamily ?? AppConstant.instance.font,
//       decoration: decoration,
//       decorationColor: decorationColor,
//     );
//
//     if (!translate) {
//       return _buildText(text, textStyle);
//     }
//
//     final selectedLanguage = ref.watch(languageProvider);
//
//     if (!isDynamic) {
//       final languageMap = AppTranslator.localTrans( text,selectedLanguage);
//
//       final value = languageMap ?? text;
//
//       return _buildText(value, textStyle);
//     }
//
//     return FutureBuilder<String>(
//       key: ValueKey('${text}_$selectedLanguage'),
//       future: AppTranslator.translate(text, selectedLanguage),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Skeletonizer(enabled: true, child: _buildText(text, textStyle));
//         }
//         final value = snapshot.data ?? text;
//
//         return _buildText(value, textStyle);
//       },
//     );
//   }
//
//   Widget _buildText(String value, TextStyle? style) {
//     return Text(
//       value,
//       maxLines: maxLines,
//       overflow: overflow ?? TextOverflow.ellipsis,
//       textAlign: textAlign,
//       style: style,
//       textScaler: TextScaler.linear(textScaleFactor),
//     );
//   }
// }
