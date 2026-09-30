import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/provider/customer_activity_provider.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'customer_activity_card.dart';

class CustomerCompleteActivity extends ConsumerWidget {
  const CustomerCompleteActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(customerActivityProvider);

    return jobsAsync.when(
      data: (allJobs) {
        final completeJobs = allJobs.where((item) {
          final statusUpper = (item.status ?? '').toUpperCase();
          return statusUpper.contains('COMPLETE');
        }).toList();

        if (completeJobs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: "No completed activities found",
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: completeJobs.length,
          itemBuilder: (context, index) {
            final item = completeJobs[index];
            final priceVal = double.tryParse(item.budgetFee ?? '') ?? 0.0;
            final contractor = item.user?.name != null
                ? "Contractor: ${item.user!.name}"
                : "Contractor: De Smet Roofing & Co";

            return CustomerActivityCard(
              activeLabel: "Active assignment",
              taskTitle: item.title ?? item.homeAsset ?? 'Task',
              contractorName: contractor,
              price: priceVal,
              status: 'Complete',
              stepStatuses: const [true, true, true, true, true],
              primaryButtonTitle: "View Invoice",
              secondaryButtonTitle: null,
              onPrimaryTap: () {
                AppRoutes.instance.pushNamed(
                  AppRoutesKey.instance.customerEvidenceScreen,
                  extra: item.id,
                );
              },
              onSecondaryTap: () {},
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
