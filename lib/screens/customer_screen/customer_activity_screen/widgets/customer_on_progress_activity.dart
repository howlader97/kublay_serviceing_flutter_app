import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/provider/customer_activity_provider.dart';
import 'package:belwork/screens/customer_screen/customer_evidence_screen/provider/customer_evidence_provider.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'customer_activity_card.dart';

class CustomerInProgressActivity extends ConsumerWidget {
  const CustomerInProgressActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(customerActivityProvider);

    return jobsAsync.when(
      data: (allJobs) {
        final onProgressJobs = allJobs.where((item) {
          final statusUpper = (item.status ?? '').toUpperCase();
          return !statusUpper.contains('COMPLETE') && statusUpper != 'PENDING';
        }).toList();

        if (onProgressJobs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: "No In-progress activities found",
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: onProgressJobs.length,
          itemBuilder: (context, index) {
            final item = onProgressJobs[index];
            final priceVal = double.tryParse(item.budgetFee ?? '') ?? 0.0;
            final contractor = item.user?.name != null
                ? "Contractor: ${item.user!.name}"
                : "Contractor: De Smet Roofing & Co";

            return Consumer(
              builder: (context, ref, child) {
                final evidenceAsync =
                    ref.watch(customerEvidenceProvider(item.id ?? ''));
                final evidences = evidenceAsync.asData?.value ?? [];
                final hasEvidence = evidences.isNotEmpty;
                final stepStatuses = [true, true, hasEvidence, hasEvidence, false];

                return CustomerActivityCard(
                  activeLabel: "Active assignment",
                  taskTitle: item.title ?? item.homeAsset ?? 'Task',
                  contractorName: contractor,
                  price: priceVal,
                  status: 'InProcess',
                  stepStatuses: stepStatuses,
                  primaryButtonTitle: "Validate",
                  secondaryButtonTitle: "See The Evidence",
                  onPrimaryTap: () {},
                  onSecondaryTap: () {
                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.customerEvidenceScreen,
                      extra: item.id,
                    );
                  },
                );
              },
            );
          },
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: AppText(
            text: "Failed to load activities",
            fontSize: 14,
            color: AppColors.instance.red73,
          ),
        ),
      ),
    );
  }
}
