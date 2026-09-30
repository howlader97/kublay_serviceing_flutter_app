import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_guest_header.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_guest_settings_list.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_header.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_settings_list.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await StorageServices.instance.getToken();
    if (token.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _isGuest = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isGuest = false;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProfileProvider.notifier).fetchProfile();
      });
    }
  }

  void logout() async {
    try {
      ref.read(userProfileProvider.notifier).clearProfile();
      ref.read(technicianProfileProvider.notifier).clearProfile();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await StorageServices.instance.logout();
      if (!mounted) return;

      AppRoutes.instance.go(AppRoutesKey.instance.signInScreen);
    } catch (e) {
      errorLog("error is ", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            children: [
              if (_isGuest) ...[
                const CustomerGuestHeader(),
                const Gap(height: 20),
                const CustomerGuestSettingsList(),
                const Gap(height: 30),
                AppButton(
                  title: 'Log In',
                  height: 48,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  onTap: () {
                    AppRoutes.instance.go(AppRoutesKey.instance.signInScreen);
                  },
                ),
              ] else ...[
                profileAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => const CustomerProfileHeader(profile: null),
                  data: (profileData) => CustomerProfileHeader(profile: profileData),
                ),
                const Gap(height: 20),
                const CustomerProfileSettingsList(),
                const Gap(height: 20),
                AppButton(
                  title: 'Log Out',
                  height: 48,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  onTap: logout,
                ),
              ],
              const Gap(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
