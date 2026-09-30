import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_image_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/services/firebase_messaging_service/firebase_messaging_service.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/app_image/app_image.dart';

final splashProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  final token = await StorageServices.instance.getToken();
  if (token.isNotEmpty) {
    await ref.read(userRoleNotifierProvider.notifier).loadRole();
    // Ensure FCM token is synced to backend on app resume/start
    FirebaseMessagingService.instance.syncDeviceToken();
    return true;
  }
  return false;
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashProvider, (previous, next) {
      next.whenData((isLoggedIn) {
        if (isLoggedIn) {
          AppRoutes.instance.go(AppRoutesKey.instance.appNavigationScreen);
        } else {
          AppRoutes.instance.go(AppRoutesKey.instance.languageScreen);
        }
      });
    });
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: AppImage(path: AppAssertsImagePath.instance.splashImage),
          ),
        ),
      ),
    );
  }
}
