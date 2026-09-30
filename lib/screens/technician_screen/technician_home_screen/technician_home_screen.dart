import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/provider/technician_home_tab_provider.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/provider/technician_opportunity_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';

import 'widgets/home_all_tab.dart';
import 'widgets/home_annual_recur_tab.dart';
import 'widgets/home_emergency_tab.dart';

class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(technicianHomeTabProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(technicianOpportunityProvider.notifier)
                .fetchJobs();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               // HomeOpportunityToggleBanner(onToggleChanged: (isEnabled) {}),
               // const Gap(height: 16),
                Row(
                  children: [
                    AppButton(
                      onTap: () {
                        ref.read(technicianHomeTabProvider.notifier).select(0);
                      },
                      backgroundColor: selectedTab == 0
                          ? AppColors.instance.primary
                          : AppColors.instance.white,
                      borderColor: selectedTab == 0
                          ? AppColors.instance.primary
                          : AppColors.instance.gray50.withValues(alpha: 0.5),
                      titleColor: selectedTab == 0
                          ? AppColors.instance.white
                          : AppColors.instance.gray4B,
                      title: "All",
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      borderRadius: BorderRadius.circular(10),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const Gap(width: 8),
                    AppButton(
                      onTap: () {
                        ref.read(technicianHomeTabProvider.notifier).select(1);
                      },
                      backgroundColor: selectedTab == 1
                          ? AppColors.instance.primary
                          : AppColors.instance.white,
                      borderColor: selectedTab == 1
                          ? AppColors.instance.primary
                          : AppColors.instance.gray50.withValues(alpha: 0.5),
                      titleColor: selectedTab == 1
                          ? AppColors.instance.white
                          : AppColors.instance.gray4B,
                      title: "Emergency",
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      borderRadius: BorderRadius.circular(10),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const Gap(width: 8),
                    AppButton(
                      onTap: () {
                        ref.read(technicianHomeTabProvider.notifier).select(2);
                      },
                      backgroundColor: selectedTab == 2
                          ? AppColors.instance.primary
                          : AppColors.instance.white,
                      borderColor: selectedTab == 2
                          ? AppColors.instance.primary
                          : AppColors.instance.gray50.withValues(alpha: 0.5),
                      titleColor: selectedTab == 2
                          ? AppColors.instance.white
                          : AppColors.instance.gray4B,
                      title: "Annual Recur",
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      borderRadius: BorderRadius.circular(10),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(height: 16),
                if (selectedTab == 0)
                  const HomeAllTab()
                else if (selectedTab == 1)
                  const HomeEmergencyTab()
                else if (selectedTab == 2)
                  const HomeAnnualRecurTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
