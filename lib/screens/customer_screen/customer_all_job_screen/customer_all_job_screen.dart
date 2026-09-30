import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/provider/technician_opportunity_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

import 'widgets/customer_job_card.dart';

class CustomerAllJobScreen extends ConsumerStatefulWidget {
  const CustomerAllJobScreen({super.key});

  @override
  ConsumerState<CustomerAllJobScreen> createState() =>
      _CustomerAllJobScreenState();
}

class _CustomerAllJobScreenState extends ConsumerState<CustomerAllJobScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(technicianOpportunityProvider.notifier).fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final jobsAsync = ref.watch(technicianOpportunityProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 14.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  BackButtonWidget(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        AppRoutes.instance.pop();
                      }
                    },
                  ),
                  const Gap(width: 14),
                  AppText(
                    text: "All Jobs",
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                ],
              ),
              const Gap(height: 16),

              // Job List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(technicianOpportunityProvider.notifier)
                        .fetchJobs();
                  },
                  child: jobsAsync.when(
                    data: (jobs) {
                      if (jobs.isEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: AppText(
                              text: "No jobs found",
                              fontSize: 14,
                              color: AppColors.instance.gray500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return CustomerJobCard(job: job);
                        },
                      );
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.instance.primary,
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text: "Failed to load jobs",
                              fontSize: 14,
                              color: AppColors.instance.error,
                            ),
                            const Gap(height: 10),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(technicianOpportunityProvider.notifier)
                                    .fetchJobs();
                              },
                              child: AppText(
                                text: "Retry",
                                fontSize: 14,
                                color: AppColors.instance.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
