import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'provider/customer_activity_provider.dart';
import 'provider/customer_activity_tab_provider.dart';
import 'widgets/customer_all_activity.dart';
import 'widgets/customer_complete_activity.dart';
import 'widgets/customer_on_progress_activity.dart';

class CustomerActivityScreen extends ConsumerStatefulWidget {
  const CustomerActivityScreen({super.key});

  @override
  ConsumerState<CustomerActivityScreen> createState() =>
      _CustomerActivityScreenState();
}

class _CustomerActivityScreenState
    extends ConsumerState<CustomerActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerActivityProvider.notifier).fetchCustomerJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final select = ref.watch(customerActivityTabProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(customerActivityProvider.notifier)
                .fetchCustomerJobs();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(height: 10),
                  AppText(
                    text: "Activity log",
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: "Secure Mobile Escrow System (Séquestre)",
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.textColor,
                  ),
                  const Gap(height: 10),
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          ref
                              .read(customerActivityTabProvider.notifier)
                              .select(0);
                        },
                        backgroundColor: select == 0
                            ? AppColors.instance.primary
                            : AppColors.instance.transparent,
                        borderColor: select == 0
                            ? AppColors.instance.primary
                            : AppColors.instance.gray4B.withValues(alpha: 0.3),
                        titleColor: select == 0
                            ? AppColors.instance.white
                            : AppColors.instance.textColor,
                        title: "All",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const Gap(width: 8),
                      AppButton(
                        onTap: () {
                          ref
                              .read(customerActivityTabProvider.notifier)
                              .select(1);
                        },
                        backgroundColor: select == 1
                            ? AppColors.instance.primary
                            : AppColors.instance.transparent,
                        borderColor: select == 1
                            ? AppColors.instance.primary
                            : AppColors.instance.gray4B.withValues(alpha: 0.3),
                        titleColor: select == 1
                            ? AppColors.instance.white
                            : AppColors.instance.textColor,
                        title: "In Progress",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const Gap(width: 8),
                      AppButton(
                        onTap: () {
                          ref
                              .read(customerActivityTabProvider.notifier)
                              .select(2);
                        },
                        backgroundColor: select == 2
                            ? AppColors.instance.primary
                            : AppColors.instance.transparent,
                        borderColor: select == 2
                            ? AppColors.instance.primary
                            : AppColors.instance.gray4B.withValues(alpha: 0.3),
                        titleColor: select == 2
                            ? AppColors.instance.white
                            : AppColors.instance.textColor,
                        title: "Complete",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                  const Gap(height: 20),
                  if (select == 0)
                    const CustomerAllActivity()
                  else if (select == 1)
                    const CustomerInProgressActivity()
                  else if (select == 2)
                    const CustomerCompleteActivity(),
                  const Gap(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
