import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/task_evidence_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_evidence_screen/provider/customer_evidence_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerEvidenceScreen extends ConsumerWidget {
  final String? jobId;

  const CustomerEvidenceScreen({super.key, this.jobId});

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final month = _monthNames[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final hourInt = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hourInt:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveJobId = jobId ?? '';
    final evidenceAsync = ref.watch(customerEvidenceProvider(effectiveJobId));

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Row(
                children: [
                  BackButtonWidget(
                    onTap: () => AppRoutes.instance.pop(),
                  ),
                  const Gap(width: 16),
                  AppText(
                    text: "Task Evidence",
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                ],
              ),
            ),
            const Gap(height: 8),

            // Body content
            Expanded(
              child: evidenceAsync.when(
                data: (evidences) {
                  if (evidences.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.find_in_page_outlined,
                              size: 64,
                              color: AppColors.instance.gray500,
                            ),
                            const Gap(height: 12),
                            AppText(
                              text: "No evidence submitted yet",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.instance.gray500,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(customerEvidenceProvider(effectiveJobId).notifier)
                          .fetchEvidences();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 8.0),
                      itemCount: evidences.length,
                      itemBuilder: (context, index) {
                        final item = evidences[index];
                        return _buildEvidenceCard(context, item);
                      },
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8.0),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.instance.containerBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: "Failed to load evidence data",
                          fontSize: 14,
                          color: AppColors.instance.red73,
                        ),
                        const Gap(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(
                                    customerEvidenceProvider(effectiveJobId).notifier)
                                .fetchEvidences();
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context, TaskEvidenceItem item) {
    final images = item.images ?? [];
    final firstImage = images.isNotEmpty ? images.first : null;
    final formattedDate = _formatDateTime(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppRoutes.instance.pushNamed(
              AppRoutesKey.instance.customerActivityEvidence,
              extra: item,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Date and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.instance.primary,
                        ),
                        const Gap(width: 6),
                        AppText(
                          text: formattedDate,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.instance.textColor,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8ED),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF34C759),
                          width: 1,
                        ),
                      ),
                      child: const AppText(
                        text: "Evidence",
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF34C759),
                      ),
                    ),
                  ],
                ),
                const Gap(height: 12),

                // Card Main Body (Image preview + Details)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (firstImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: AppImage(
                            url: firstImage,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Gap(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.job?.title != null &&
                              item.job!.title!.isNotEmpty) ...[
                            AppText(
                              text: item.job!.title!,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.instance.textColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(height: 4),
                          ],
                          AppText(
                            text: "Summary: ${item.summary ?? 'No summary'}",
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.instance.textColor,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const Gap(height: 4),
                            AppText(
                              text: "Note: ${item.note}",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.instance.gray500,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(height: 12),

                // Bottom row: Image count & Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const Gap(width: 4),
                        AppText(
                          text: "${images.length} Image(s)",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.instance.gray500,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppText(
                          text: "View Evidence",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.instance.primary,
                        ),
                        const Gap(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.instance.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
