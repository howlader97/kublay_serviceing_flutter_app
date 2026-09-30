import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/task_evidence_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_activity_evidence/widgets/review_container.dart';
import 'package:belwork/screens/customer_screen/customer_activity_evidence/widgets/revision_bottom_widget.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

final ratingProvider = StateProvider<int>((ref) => -1);

class CustomerActivityEvidence extends StatefulWidget {
  final TaskEvidenceItem? evidenceItem;

  const CustomerActivityEvidence({super.key, this.evidenceItem});

  @override
  State<CustomerActivityEvidence> createState() =>
      _CustomerActivityEvidenceState();
}

class _CustomerActivityEvidenceState extends State<CustomerActivityEvidence> {
  int _currentImageIndex = 0;

  static const List<String> _sampleImages = [
    "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600",
    "https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600",
    "https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600",
  ];

  static const List<String> _monthNames = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final month = _monthNames[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final hourInt = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'Pm' : 'Am';

    return '${hourInt.toString().padLeft(2, '0')}:$minuteStr $period ($day/$month/$year)';
  }

  List<String> get _displayImages {
    if (widget.evidenceItem?.images != null &&
        widget.evidenceItem!.images!.isNotEmpty) {
      return widget.evidenceItem!.images!;
    }
    return _sampleImages;
  }

  @override
  Widget build(BuildContext context) {
    final evidence = widget.evidenceItem;
    final images = _displayImages;
    final issueName =
        evidence?.job?.title ?? evidence?.job?.homeAsset ?? "Water Leak";
    final summary = evidence?.summary ?? "N/A";
    final note = evidence?.note ?? "";
    final descriptionText =
        note.isNotEmpty ? "$summary\nNote: $note" : summary;
    final timeStr = _formatDateTime(evidence?.createdAt);
    final endTimeStr = _formatDateTime(evidence?.updatedAt);
    final statusStr = evidence?.job?.status ?? "Completed";

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    const Gap(width: 16),
                    AppText(
                      text: "Task evidence",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.textColor,
                    ),
                  ],
                ),
                const Gap(height: 16),

                // Main Evidence Card Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.instance.containerBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 166,
                              width: double.infinity,
                              child: AppImage(
                                url: images.isNotEmpty
                                    ? images[_currentImageIndex % images.length]
                                    : '',
                                width: double.infinity,
                                height: 166,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: AppText(
                                text: statusStr,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          if (images.length > 1) ...[
                            Positioned(
                              left: 12,
                              top: 65,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentImageIndex = (_currentImageIndex -
                                            1 +
                                            images.length) %
                                        images.length;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 65,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentImageIndex =
                                        (_currentImageIndex + 1) % images.length;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.instance.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (index) {
                                  final isActive =
                                      index == (_currentImageIndex % images.length);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 3),
                                    width: 24,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.instance.primary
                                          : Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(height: 20),

                      _buildDetailRow(label: "Issue name:", value: issueName),
                      const Gap(height: 8),
                      _buildDetailRow(
                        label: "Descriptions:",
                        value: descriptionText,
                      ),
                      const Gap(height: 8),
                      _buildDetailRow(label: "Time:", value: timeStr),
                      const Gap(height: 8),
                      _buildDetailRow(label: "End Time:", value: endTimeStr),
                      const Gap(height: 8),
                      _buildDetailRow(label: "Statas:", value: statusStr),
                      const Gap(height: 24),

                      AppButton(
                        onTap: () {
                          final jobId =
                              evidence?.jobId ?? evidence?.job?.id ?? '';
                          final userId = evidence?.job?.userId ?? '';
                          final professionalId =
                              evidence?.job?.professionalId ?? '';

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: ReviewContainer(
                                  jobId: jobId,
                                  userId: userId,
                                  professionalId: professionalId,
                                ),
                              );
                            },
                          );
                        },
                        title: "Complete & Rate",
                        backgroundColor: AppColors.instance.primary,
                        titleColor: AppColors.instance.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      const Gap(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              onTap: () {
                                final jobId =
                                    evidence?.jobId ?? evidence?.job?.id ?? '';

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                      ),
                                      child: RevisionBottomWidget(jobId: jobId),
                                    );
                                  },
                                );
                              },
                              title: "Revision",
                              backgroundColor: const Color(0xFFF9F3F5),
                              borderColor: AppColors.instance.primary,
                              titleColor: AppColors.instance.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              borderRadius: BorderRadius.circular(8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const Gap(width: 12),
                          Expanded(
                            child: AppButton(
                              onTap: () {
                                AppRoutes.instance.pushNamed(
                                  AppRoutesKey.instance.customerInvoiceScreen,
                                );
                              },
                              title: "View Invoice",
                              backgroundColor: const Color(0xFFF9F3F5),
                              borderColor: AppColors.instance.primary,
                              titleColor: AppColors.instance.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              borderRadius: BorderRadius.circular(8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: AppColors.instance.textColor),
        children: [
          TextSpan(
            text: "$label ",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.instance.textColor),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray4B),
          ),
        ],
      ),
    );
  }
}
