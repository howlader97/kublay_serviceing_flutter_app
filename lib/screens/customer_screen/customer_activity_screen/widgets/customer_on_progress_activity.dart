import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/provider/customer_activity_provider.dart';
import 'package:belwork/screens/customer_screen/customer_evidence_screen/provider/customer_evidence_provider.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'customer_activity_card.dart';

class CustomerInProgressActivity extends ConsumerStatefulWidget {
  const CustomerInProgressActivity({super.key});

  @override
  ConsumerState<CustomerInProgressActivity> createState() =>
      _CustomerInProgressActivityState();
}

class _CustomerInProgressActivityState
    extends ConsumerState<CustomerInProgressActivity> {
  final Set<String> _loadingJobIds = {};
  final Set<String> _recentlyCompletedIds = {};

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(customerActivityProvider);

    return jobsAsync.when(
      data: (allJobs) {
        final onProgressJobs = allJobs.where((item) {
          if (item.id != null && _recentlyCompletedIds.contains(item.id)) {
            return true;
          }
          final statusUpper = (item.status ?? '').toUpperCase();
          return !statusUpper.contains('COMPLETE') &&
              statusUpper != 'FINISHED' &&
              statusUpper != 'PENDING';
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
            final statusUpper = (item.status ?? '').toUpperCase();
            final isFinished = statusUpper == 'FINISHED' ||
                statusUpper.contains('COMPLETE') ||
                (item.id != null && _recentlyCompletedIds.contains(item.id));
            final priceVal = double.tryParse(item.budgetFee ?? '') ?? 0.0;
            final contractor = item.user?.name != null
                ? "Contractor: ${item.user!.name}"
                : "Contractor: De Smet Roofing & Co";

            final isJobLoading =
                item.id != null && _loadingJobIds.contains(item.id);

            return Consumer(
              builder: (context, ref, child) {
                List<bool> stepStatuses;
                if (isFinished) {
                  stepStatuses = const [true, true, true, true, true];
                } else {
                  final evidenceAsync =
                      ref.watch(customerEvidenceProvider(item.id ?? ''));
                  final evidences = evidenceAsync.asData?.value ?? [];
                  final hasEvidence = evidences.isNotEmpty;
                  stepStatuses = [true, true, hasEvidence, hasEvidence, false];
                }

                return CustomerActivityCard(
                  activeLabel: "Active assignment",
                  taskTitle: item.title ?? item.homeAsset ?? 'Task',
                  contractorName: contractor,
                  price: priceVal,
                  status: isFinished ? 'Finished' : 'InProcess',
                  stepStatuses: stepStatuses,
                  primaryButtonTitle: isFinished ? "View Invoice" : "Validate",
                  secondaryButtonTitle: isFinished ? null : "See The Evidence",
                  isPrimaryLoading: isJobLoading,
                  onPrimaryTap: () async {
                    if (isFinished) {
                      AppRoutes.instance.pushNamed(
                        AppRoutesKey.instance.customerInvoiceScreen,
                      );
                    } else if (item.id != null) {
                      setState(() {
                        _loadingJobIds.add(item.id!);
                        _recentlyCompletedIds.add(item.id!);
                      });
                      final success = await ref
                          .read(customerActivityProvider.notifier)
                          .completeJob(item.id!);
                      if (mounted) {
                        setState(() {
                          _loadingJobIds.remove(item.id!);
                          if (!success) {
                            _recentlyCompletedIds.remove(item.id!);
                          }
                        });
                      }
                    }
                  },
                  onSecondaryTap: () {
                    if (!isFinished) {
                      AppRoutes.instance.pushNamed(
                        AppRoutesKey.instance.customerEvidenceScreen,
                        extra: item.id,
                      );
                    }
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
