import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/company_employee_profile_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_screen/provider/company_employee_profile_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_guest_settings_list.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_row.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
 // bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyEmployeeProfileProvider.notifier).fetchProfile();
    });
  }

  void logout() async {
    try {
      ref.read(userProfileProvider.notifier).clearProfile();
      ref.read(technicianProfileProvider.notifier).clearProfile();
      ref.read(companyEmployeeProfileProvider.notifier).clearProfile();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await StorageServices.instance.logout();
      if (!mounted) return;

      AppRoutes.instance.go(AppRoutesKey.instance.signInScreen);
    } catch (e) {
      errorLog("Error is", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(companyEmployeeProfileProvider);
    final profileData = profileState.profileResponse?.data;
    final userData = profileData?.user;

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.instance.primary,
          onRefresh: () async {
            await ref
                .read(companyEmployeeProfileProvider.notifier)
                .fetchProfile(showLoading: false);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            child: profileState.isLoading && profileData == null
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.instance.primary,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const Gap(height: 10),
                      _buildTopHeader(profileData, userData),
                      const Gap(height: 20),
                      _buildSettingsList(context, profileData, userData),
                      const Gap(height: 20),
                      AppButton(
                        title: 'Log Out',
                        height: 48,
                        backgroundColor: AppColors.instance.containerBackground,
                        borderColor: AppColors.instance.containerBackground,
                        titleColor: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        onTap: () {
                          logout();
                        },
                      ),
                      const Gap(height: 10),
                      AppButton(
                        title: 'Delete account',
                        height: 48,
                        backgroundColor: AppColors.instance.primary,
                        titleColor: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        onTap: () {},
                      ),
                      const Gap(height: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    CompanyEmployeeProfileData? profileData,
    CompanyEmployeeUser? userData,
  ) {
    final avatarUrl = (userData?.avatar != null && userData!.avatar!.isNotEmpty)
        ? userData.avatar!
        : "https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768";

    final name = (userData?.name != null && userData!.name!.isNotEmpty)
        ? userData.name!
        : "Employee Profile";

    final email = userData?.email ?? "";

    final designation = profileData?.designation ?? "Employee";
    final skill = profileData?.skill ?? "";
    final designationText = skill.isNotEmpty
        ? "Designation: $designation ($skill)"
        : "Designation: $designation";

    return Column(
      children: [
        Center(
          child: AppImageCircular(

            url: avatarUrl,
            height: 90,
            width: 90,
            color: AppColors.instance.containerBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: name,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.instance.textColor14,
            ),
            Gap(width: 10,),
            GestureDetector(
              onTap: (){
                AppRoutes.instance.push(AppRoutesKey.instance.companyProfileEditScreen);
              },
                child: Icon(Icons.edit,color: AppColors.instance.textColor14,))
          ],
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          AppText(
            text: email,
            fontSize: 14,
            color: AppColors.instance.textColor14,
          ),
        ],
        const SizedBox(height: 4),
        AppText(
          text: designationText,
          fontSize: 14,
          color: AppColors.instance.textColor14,
        ),
      ],
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    CompanyEmployeeProfileData? profileData,
    CompanyEmployeeUser? userData,
  ) {
    final selectedLanguage = ref.watch(languageProvider);

    return Column(
      children: [
        CustomerProfileRow(
          title: "Language",
          subTitle: CustomerGuestSettingsList.getLanguageName(selectedLanguage),
          onTap: () {
            AppRoutes.instance.pushNamed(
              AppRoutesKey.instance.allLanguageScreen,
            );
          },
        ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Privacy",
          subTitle: "your data & security",
          onTap: () {
            AppRoutes.instance.pushNamed(
              AppRoutesKey.instance.privacyPolicyScreen,
            );
          },
        ),
        _buildDivider(),
        _buildDivider(),
        CustomerProfileRow(
          title: "Terms & Condition",
          subTitle: "your terms & condition",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.termsAndConditionsScreen);
          },
        ),
        // CustomerProfileRow(
        //   title: "Biometric logging",
        //   subTitle: "Fingerprint",
        //   trailing: Switch(
        //     value: _biometricEnabled,
        //     onChanged: (val) {
        //       setState(() {
        //         _biometricEnabled = val;
        //       });
        //     },
        //     thumbColor: WidgetStateProperty.resolveWith((states) {
        //       return Colors.white;
        //     }),
        //     trackColor: WidgetStateProperty.resolveWith((states) {
        //       if (states.contains(WidgetState.selected)) {
        //         return AppColors.instance.primary;
        //       }
        //       return Colors.grey.shade300;
        //     }),
        //   ),
        //   onTap: () {},
        // ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300.withValues(alpha: 0.6),
      height: 16,
      thickness: 1,
    );
  }
}
