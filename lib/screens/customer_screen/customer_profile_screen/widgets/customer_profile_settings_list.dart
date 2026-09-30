import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_guest_settings_list.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_row.dart';
import 'package:belwork/utils/languages/language_provider.dart';

class CustomerProfileSettingsList extends ConsumerWidget {
  const CustomerProfileSettingsList({super.key});

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300.withValues(alpha: 0.6),
      height: 16,
      thickness: 1,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(languageProvider);

    return Column(
      children: [
        CustomerProfileRow(
          title: "BELPRO",
          subTitle: "Subcontracting and business",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerAllJobScreen);
          },
        ),
        _buildDivider(),
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
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerRegionSubsidyGrants);
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
          subTitle: "your terms & condition",
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
        //   title: "Subscription",
        //   subTitle: "Manage subscription",
        //   onTap: () {
        //     AppRoutes.instance
        //         .pushNamed(AppRoutesKey.instance.customerSubscriptionScreen);
        //   },
        // ),
        _buildDivider(),
        CustomerProfileRow(
          title: "Delete account",
          subTitle: "If you want to delete account",
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerDeleteAccountScreen);
          },
        ),
      ],
    );
  }
}
