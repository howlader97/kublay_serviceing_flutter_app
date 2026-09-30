import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/main_app_entry.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class AppSnackBar {
  // -------- Singleton Setup --------
  AppSnackBar._privateConstructor();
  static final AppSnackBar instance = AppSnackBar._privateConstructor();

  BuildContext? get _context => rootNavigatorKey.currentContext;

  // -------- Snackbar Methods --------
  void error(String message, {bool showTop = true}) {
    try {
      if (showTop) {
        final overlay = appOverlayKey.currentState;
        if (overlay == null) return;

        OverlayEntry overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: AppSize.width(value: 50),
            left: AppSize.width(value: 20),
            right: AppSize.width(value: 20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(AppSize.width(value: 14)),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: message,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );

        overlay.insert(overlayEntry);

        Future.delayed(
          const Duration(seconds: 2),
        ).then((_) => overlayEntry.remove());
      } else {
        if (_context == null) return;

        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(
              horizontal: AppSize.width(value: 20),
              vertical: AppSize.width(value: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: AppText(
              text: message,
              color: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      errorLog("error", e);
    }
  }

  void success(String message, {Duration? duration, bool showTop = true}) {
    if (showTop) {
      final overlay = appOverlayKey.currentState;
      if (overlay == null) return;

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: AppSize.width(value: 50),
          left: AppSize.width(value: 20),
          right: AppSize.width(value: 20),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(AppSize.width(value: 14)),
              decoration: BoxDecoration(
                color: AppColors.instance.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                text: message,
                color: AppColors.instance.white50,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      Future.delayed(
        const Duration(seconds: 2),
      ).then((_) => overlayEntry.remove());
    } else {
      if (_context == null) return;

      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.instance.success,
          duration: duration ?? const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: AppSize.width(value: 20),
            vertical: AppSize.width(value: 20),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.width(value: 5)),
          ),
          content: AppText(
            text: message,
            color: AppColors.instance.white50,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  void message(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    bool showTop = true,
  }) {
    if (showTop) {
      final overlay = appOverlayKey.currentState;
      if (overlay == null) return;

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: AppSize.width(value: 50),
          left: AppSize.width(value: 20),
          right: AppSize.width(value: 20),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(AppSize.width(value: 14)),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.instance.dark300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                text: message,
                color: textColor ?? AppColors.instance.white300,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      Future.delayed(
        const Duration(seconds: 2),
      ).then((_) => overlayEntry.remove());
    } else {
      if (_context == null) return;

      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor ?? AppColors.instance.dark300,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: AppSize.width(value: 20),
            vertical: AppSize.width(value: 20),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.width(value: 5)),
          ),
          content: AppText(
            text: message,
            color: textColor ?? AppColors.instance.white300,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
  }

  /// In-App Notification Banner (shown on top when foreground message is received)
  void showNotificationBanner({
    required String title,
    required String body,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    try {
      final overlay = appOverlayKey.currentState;
      if (overlay == null) return;

      late OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: AppSize.width(value: 45),
          left: AppSize.width(value: 16),
          right: AppSize.width(value: 16),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                if (overlayEntry.mounted) {
                  overlayEntry.remove();
                }
                onTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.instance.primary.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.instance.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.instance.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: title,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.textColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (body.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            AppText(
                              text: body,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.instance.gray500,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (overlayEntry.mounted) {
                          overlayEntry.remove();
                        }
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.instance.gray400,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      Future.delayed(duration).then((_) {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    } catch (e) {
      errorLog("showNotificationBanner", e);
    }
  }
}
