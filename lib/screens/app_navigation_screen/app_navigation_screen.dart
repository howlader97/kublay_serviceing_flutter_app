import 'package:belwork/screens/chat_screen/message_screen/message_screen.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/dialogs/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/app_navigation_screen/provider/navigation_provider.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/company_agenda_screen.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_screen/company_profile_screen.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/customer_activity_screen.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/customer_home_screen.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/customer_planner_screen.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/customer_profile_screen.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/technician_home_screen.dart';
import 'package:belwork/screens/technician_screen/technician_manage_screen/technician_manage_screen.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/technician_planner_screen.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/technician_profile_screen.dart';

import 'package:belwork/widgets/texts/app_text.dart';
import '../../constant/app_asserts_icons_path.dart';

class AppNavigationScreen extends ConsumerWidget {
  const AppNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleNotifierProvider);

    return userRoleAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.instance.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => _buildNavigationContent(context, ref, "CUSTOMER"),
      data: (role) => _buildNavigationContent(context, ref, role),
    );
  }

  Widget _buildNavigationContent(BuildContext context, WidgetRef ref, String role) {
    final selectIndex = ref.watch(navigationProvider);
    final List<Widget> pages;
    final List<String> labels;
    final List<String> icons;

    final isCustomer = role.trim().toUpperCase() == "CUSTOMER" || role.trim().toUpperCase() == "USER";
    final isProfessional = role.trim().toUpperCase() == "PROFESSIONAL" || role.trim().toUpperCase() == "BUSINESS";

    if (isCustomer) {
      pages = const [CustomerHomeScreen(), CustomerActivityScreen(), CustomerPlannerScreen(), MessageScreen(), CustomerProfileScreen()];
      labels = const ["  Home  ", "Activity", "Publish", "  Chat  ", "Profile "];
      icons = [
        AppAssertsIconsPath.instance.homeIcon,
        AppAssertsIconsPath.instance.activity,
        AppAssertsIconsPath.instance.plannerIcon,
        AppAssertsIconsPath.instance.chatIcon,
        AppAssertsIconsPath.instance.profileIcon,
      ];
    } else if (isProfessional) {
      pages = const [TechnicianHomeScreen(), TechnicianManageScreen(), TechnicianPlannerScreen(), MessageScreen(), TechnicianProfileScreen()];
      labels = const [" Home ", "Manage", "Planner", "  Chat  ", "Profile"];
      icons = [
        AppAssertsIconsPath.instance.homeIcon,
        AppAssertsIconsPath.instance.manageIcon,
        AppAssertsIconsPath.instance.plannerIcon,
        AppAssertsIconsPath.instance.chatIcon,
        AppAssertsIconsPath.instance.profileIcon,
      ];
    } else {
      pages = const [CompanyAgendaScreen(), MessageScreen(), CompanyProfileScreen()];
      labels = const ["Agenda", "   Chat   ", " Profile "];
      icons = [AppAssertsIconsPath.instance.plannerIcon, AppAssertsIconsPath.instance.chatIcon, AppAssertsIconsPath.instance.profileIcon];
    }

    final safeIndex = (selectIndex >= 0 && selectIndex < pages.length) ? selectIndex : 0;

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      // body: pages[safeIndex],
      body: IndexedStack(
        index: safeIndex,
        children:pages ,

      ),
      bottomNavigationBar: Container(
        height: 90,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: AppColors.instance.containerBackground),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(pages.length, (index) {
              final isSelected = safeIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (index == 1 || index == 2 || index == 3) {
                      final token = await StorageServices.instance.getToken();
                      if (token.trim().isEmpty) {
                        if (context.mounted) {
                          showLoginRequiredDialog(
                            context,
                            message: "You need to log in to access ${labels[index].trim()}.",
                          );
                        }
                        return;
                      }
                    }
                    ref.read(navigationProvider.notifier).state = index;
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isSelected ? AppColors.instance.white50 : Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            scale: 4,
                            icons[index],
                            color: isSelected ? AppColors.instance.primary : AppColors.instance.textColor,
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppText(
                              text: labels[index],
                              fontSize: 12,
                              maxLines: 1,
                              fontWeight: FontWeight.w400,
                              color: isSelected ? AppColors.instance.primary : AppColors.instance.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
