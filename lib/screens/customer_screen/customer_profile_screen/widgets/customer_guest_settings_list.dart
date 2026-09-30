import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/widgets/customer_profile_row.dart';
import 'package:belwork/utils/languages/language_provider.dart';

class CustomerGuestSettingsList extends ConsumerWidget {
  const CustomerGuestSettingsList({super.key});

  static String getLanguageName(String code) {
    switch (code) {
      case "en_US":
        return "English";
      case "fr_FR":
        return "Français";
      case "nl_NL":
        return "Néerlandais";
      case "de_DE":
        return "Allemand";
      case "pl_PL":
        return "Polonais";
      case "uk_UA":
        return "Ukrainien";
      case "bg_BG":
        return "Bulgare";
      case "ar_SA":
        return "Arabe";
      case "tr_TR":
        return "Turc";
      case "ro_RO":
        return "Roumain";
      case "es_ES":
        return "Espagnol";
      case "it_IT":
        return "Italien";
      case "pt_PT":
        return "Portugais";
      default:
        return "English";
    }
  }

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
          title: "Language",
          subTitle: getLanguageName(selectedLanguage),
          onTap: () {
            AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.allLanguageScreen);
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
      ],
    );
  }
}
