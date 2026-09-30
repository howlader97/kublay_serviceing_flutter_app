import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_row.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_guest_settings_list.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';


class TechnicianProfileScreen extends ConsumerStatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  ConsumerState<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState
    extends ConsumerState<TechnicianProfileScreen> {
 // bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(technicianProfileProvider.notifier).fetchProfileDetails();
    });
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
      errorLog("Log error", e);
    }
  }

  String _formatAvailability(String availability) {
    final upper = availability.toUpperCase();
    if (upper.contains('FULL')) {
      return 'Available Full Week';
    } else if (upper.contains('WEEKEND')) {
      return 'Available Weekends';
    } else if (upper.contains('WEEKDAY')) {
      return 'Available Weekdays';
    }
    return availability.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(technicianProfileProvider);
    final professionalData =
        profileState.profileDetails?.data?.professional;
    final userData = professionalData?.user;
   // final services = profileState.profileDetails?.data?.allServices ?? [];

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: profileState.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.instance.primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(technicianProfileProvider.notifier)
                      .fetchProfileDetails();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 14.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(
                        name: userData?.name ?? " ",
                        avatar: userData?.avatar,
                      ),
                      const Gap(height: 20),
                      _buildBalanceCard(
                        hourlyRate: professionalData?.hourlyRate,
                      ),
                      const Gap(height: 10),
                      AppButton(
                        title: 'Withdraw net earnings',
                        height: 48,
                        backgroundColor: AppColors.instance.primary,
                        titleColor: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        onTap: () {},
                      ),
                      const Gap(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.instance.containerBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Open hour",
                              fontSize: 12,
                              color: AppColors.instance.gray4B,
                            ),
                            AppText(
                              text: (professionalData?.workingTimeStart != null &&
                                      professionalData!.workingTimeStart!.isNotEmpty)
                                  ? professionalData.workingTimeStart!
                                  : (professionalData?.workingTime?.split('-').firstOrNull ?? "8:00"),
                              fontSize: 16,
                              color: AppColors.instance.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            const Gap(height: 8),
                            AppText(
                              text: "Close hour",
                              fontSize: 12,
                              color: AppColors.instance.gray4B,
                            ),
                            AppText(
                              text: (professionalData?.workingTimeEnd != null &&
                                      professionalData!.workingTimeEnd!.isNotEmpty)
                                  ? professionalData.workingTimeEnd!
                                  : (professionalData?.workingTime?.split('-').lastOrNull ?? "16:00"),
                              fontSize: 16,
                              color: AppColors.instance.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            const Gap(height: 8),
                            AppText(
                              text: "Dispatch zone (KM)",
                              fontSize: 12,
                              color: AppColors.instance.gray4B,
                            ),
                            AppText(
                              text: (professionalData?.workingRadiusKmLatitude != null &&
                                  professionalData!.workingRadiusKmLatitude!.isNotEmpty)
                                  ? double.tryParse(
                                professionalData.workingRadiusKmLatitude!,
                              )?.toStringAsFixed(1) ??
                                  "10.0"
                                  : "10.0",
                              fontSize: 16,
                              color: AppColors.instance.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            // AppText(
                            //   text: (professionalData?.workingRadiusKmLatitude !=
                            //               null &&
                            //           professionalData!
                            //               .workingRadiusKmLatitude!.isNotEmpty)
                            //       ? professionalData.workingRadiusKmLatitude!
                            //       : "10",
                            //   fontSize: 16,
                            //   color: AppColors.instance.textColor,
                            //   fontWeight: FontWeight.w600,
                            // ),
                            if (professionalData?.corporateVatNumber != null &&
                                professionalData!.corporateVatNumber!.isNotEmpty) ...[
                              const Gap(height: 8),
                              AppText(
                                text: "Corporate VAT",
                                fontSize: 12,
                                color: AppColors.instance.gray4B,
                              ),
                              AppText(
                                text: professionalData.corporateVatNumber!,
                                fontSize: 16,
                                color: AppColors.instance.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                            if (professionalData?.availability != null &&
                                professionalData!.availability!.isNotEmpty) ...[
                              const Gap(height: 8),
                              AppText(
                                text: "Availability",
                                fontSize: 12,
                                color: AppColors.instance.gray4B,
                              ),
                              AppText(
                                text: _formatAvailability(
                                  professionalData.availability!,
                                ),
                                fontSize: 16,
                                color: AppColors.instance.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ],

                          ],
                        ),
                      ),
                      const Gap(height: 10),
                      // const CatelogButton(),
                      // const Gap(height: 10),
                      // if (services.isNotEmpty)
                      //   SizedBox(
                      //     height: 190,
                      //     child: GridView.builder(
                      //       gridDelegate:
                      //           const SliverGridDelegateWithFixedCrossAxisCount(
                      //         crossAxisCount: 1,
                      //         crossAxisSpacing: 16,
                      //         mainAxisSpacing: 16,
                      //         childAspectRatio: 1.1,
                      //       ),
                      //       shrinkWrap: true,
                      //       itemCount: services.length,
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (context, index) {
                      //         final serviceItem = services[index];
                      //         print("service: ${serviceItem.priorityLevel}");
                      //
                      //         return CategoryCard(
                      //           image: (serviceItem.avatar != null &&
                      //                   serviceItem.avatar!.isNotEmpty)
                      //               ? serviceItem.avatar!
                      //               : "https://images.unsplash.com/photo-1542013936693-884638332954?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      //           title: serviceItem.priorityLevel == "HIGH_URGENCY" ? "Emergency" : " ",
                      //           service: 'Regular',
                      //           priceText:
                      //               'Rates from €${serviceItem.price ?? '0'}/hr',
                      //         );
                      //       },
                      //     ),
                      //   )
                      // else
                      //   SizedBox(
                      //     height: 60,
                      //     child: Center(child: AppText(text: "No catalog found",color: AppColors.instance.black,)),
                      //   ),
                       const Gap(height: 5),
                      //const Gap(height: 10),
                      _buildSettingsList(context),
                      const Gap(height: 20),
                      AppButton(
                        title: 'Log Out',
                        height: 48,
                        backgroundColor: AppColors.instance.primary,
                        titleColor: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        onTap: () {
                          logout();
                        },
                      ),
                      const Gap(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTopHeader({required String name, String? avatar}) {
    return Column(
      children: [
        Center(
          child: AppImageCircular(
            url: (avatar != null && avatar.isNotEmpty)
                ? avatar
                : "https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768",
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
            const SizedBox(width: 8),
            BackButtonWidget(
              onTap: () {
                AppRoutes.instance
                    .pushNamed(AppRoutesKey.instance.technicianProfileEditScreen);
              },
              width: 28,
              height: 28,
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard({String? hourlyRate}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.instance.containerBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 114,
            child: Column(
              children: [
                AppText(
                  text: "€1200",
                  color: AppColors.instance.green59,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(height: 10),
                AppText(
                  text: "Net earning",
                  fontSize: 14,
                  color: AppColors.instance.textColor14,
                ),
              ],
            ),
          ),
        ),
        const Gap(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.instance.containerBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 114,
            child: Column(
              children: [
                AppText(
                  text: "€1200",
                  color: AppColors.instance.red3c,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(height: 10),
                AppText(
                  text: "Pending",
                  fontSize: 14,
                  color: AppColors.instance.textColor14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final selectedLanguage = ref.watch(languageProvider);

    return Column(
      children: [
        CustomerProfileRow(
          title: "Language",
          subTitle: CustomerGuestSettingsList.getLanguageName(selectedLanguage),
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.allLanguageScreen);
          },
        ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Password",
          subTitle: "Manage your password",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerEditPassword);
          },
        ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Regional Subsidy Tracker",
          subTitle: "Flanders • Brussels • Wallonia",
          onTap: () {
            AppRoutes.instance.pushNamed(
                AppRoutesKey.instance.customerRegionSubsidyGrants);
          },
        ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Privacy",
          subTitle: "Your data & security",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.privacyPolicyScreen);
          },
        ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Terms & Condition",
          subTitle: "Your terms & condition",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.termsAndConditionsScreen);
          },
        ),
         _buildDivider(),
        CustomerProfileRow(
          title: "About Us",
          subTitle: "about us",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.aboutUsScreen);
          },
        ),
        // _buildDivider(),
        // CustomerProfileRow(
        //   title: "Payment methods",
        //   subTitle: "Stripe/Bancontact",
        //   onTap: () {},
        // ),
        _buildDivider(),
        CustomerProfileRow(
          title: "My rating",
          subTitle: "Manage rating",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerReviewScreen);
          },
        ),
        // _buildDivider(),
        // CustomerProfileRow(
        //   title: "Subscription",
        //   subTitle: "Manage subscription",
        //   onTap: () {
        //     AppRoutes.instance
        //         .pushNamed(AppRoutesKey.instance.customerSubscriptionScreen);
        //   },
        // ),
        // _buildDivider(),
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
        //       if (states.contains(WidgetState.selected)) {
        //         return Colors.white;
        //       }
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
        _buildDivider(),
        CustomerProfileRow(
          title: "Delete account",
          subTitle: "If you want to delete account",
          onTap: () {
            AppRoutes.instance.pushNamed(
                AppRoutesKey.instance.customerDeleteAccountScreen);
          },
        ),
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
