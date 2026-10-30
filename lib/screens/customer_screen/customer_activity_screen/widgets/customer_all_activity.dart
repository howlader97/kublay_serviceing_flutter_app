import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_activity_screen/provider/customer_activity_provider.dart';
import 'package:belwork/screens/customer_screen/customer_evidence_screen/provider/customer_evidence_provider.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'customer_activity_card.dart';

class CustomerAllActivity extends ConsumerStatefulWidget {
  const CustomerAllActivity({super.key});

  @override
  ConsumerState<CustomerAllActivity> createState() =>
      _CustomerAllActivityState();
}

class _CustomerAllActivityState extends ConsumerState<CustomerAllActivity> {
  final Set<String> _loadingJobIds = {};

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(customerActivityProvider);

    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: "No active activities found",
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final item = jobs[index];
            final statusUpper = (item.status ?? '').toUpperCase();
            final isFinished =
                statusUpper == 'FINISHED' || statusUpper.contains('COMPLETE');
            final isPending = statusUpper == 'PENDING';
            final priceVal = double.tryParse(item.budgetFee ?? '') ?? 0.0;
            final contractor = item.user?.name != null
                ? "Contractor: ${item.user!.name}"
                : "Contractor: De Smet Roofing & Co";

            String displayStatus = 'InProcess';
            String? primaryBtn = "Validate";
            String? secondaryBtn = "See The Evidence";

            if (isFinished) {
              displayStatus = 'Finished';
              primaryBtn = "View Invoice";
              secondaryBtn = null;
            } else if (isPending) {
              displayStatus = 'Pending';
              primaryBtn = null;
              secondaryBtn = null;
            }

            final isJobLoading =
                item.id != null && _loadingJobIds.contains(item.id);

            return Consumer(
              builder: (context, ref, child) {
                List<bool> stepStatuses = const [true, true, false, false, false];

                if (isFinished) {
                  stepStatuses = const [true, true, true, true, true];
                } else if (isPending) {
                  stepStatuses = const [false, false, false, false, false];
                } else {
                  final evidenceAsync =
                      ref.watch(customerEvidenceProvider(item.id ?? ''));
                  final evidences = evidenceAsync.asData?.value ?? [];
                  final hasEvidence = evidences.isNotEmpty;
                  stepStatuses = [true, true, hasEvidence, hasEvidence, false];
                }

                return CustomerActivityCard(
                  activeLabel: isPending ? "Pending assignment" : "Active assignment",
                  taskTitle: item.title ?? item.homeAsset ?? 'Task',
                  contractorName: contractor,
                  price: priceVal,
                  status: displayStatus,
                  stepStatuses: stepStatuses,
                  primaryButtonTitle: primaryBtn,
                  secondaryButtonTitle: secondaryBtn,
                  isPrimaryLoading: isJobLoading,
                  onPrimaryTap: () async {
                    if (isFinished) {
                      AppRoutes.instance.pushNamed(
                        AppRoutesKey.instance.customerInvoiceScreen,
                      );
                    } else if (!isPending) {
                      if (item.id != null) {
                        setState(() {
                          _loadingJobIds.add(item.id!);
                        });
                        await ref
                            .read(customerActivityProvider.notifier)
                            .completeJob(item.id!);
                        if (mounted) {
                          setState(() {
                            _loadingJobIds.remove(item.id!);
                          });
                        }
                      }
                    }
                  },
                  onSecondaryTap: () {
                    if (secondaryBtn != null) {
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
