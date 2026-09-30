import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerJobCard extends StatelessWidget {
  final TechnicianJobItem? job;
  final String? title;
  final String? status;
  final String? price;
  final String? address;
  final String? description;
  final String? customerName;
  final String? wishDate;
  final String? recurrenceType;
  final String? urgency;
  final List<String>? images;
  final VoidCallback? onTap;

  const CustomerJobCard({
    super.key,
    this.job,
    this.title,
    this.status,
    this.price,
    this.address,
    this.description,
    this.customerName,
    this.wishDate,
    this.recurrenceType,
    this.urgency,
    this.images,
    this.onTap,
  });

  static String _formatPrice(String? budgetFee) {
    if (budgetFee == null || budgetFee.trim().isEmpty) return "€0";
    final trimmed = budgetFee.trim();
    if (trimmed.startsWith('€') || trimmed.startsWith('\$')) {
      return trimmed;
    }
    final numVal = double.tryParse(trimmed);
    if (numVal != null) {
      if (numVal == numVal.toInt().toDouble()) {
        return "€${numVal.toInt()}";
      }
      return "€${numVal.toStringAsFixed(2)}";
    }
    return "€$trimmed";
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusBgColor(String statusText) {
    final s = statusText.toUpperCase();
    if (s.contains('PENDING')) {
      return const Color(0xFFFEF7E0);
    } else if (s.contains('PROCESS') || s.contains('PROGRESS')) {
      return const Color(0xFFEBF3FF);
    } else if (s.contains('COMPLETE') ||
        s.contains('APPROVED') ||
        s.contains('DONE') ||
        s.contains('ACTIVE')) {
      return const Color(0xFFEAF8ED);
    } else if (s.contains('CANCEL') || s.contains('REJECT')) {
      return const Color(0xFFFFEBEE);
    }
    return const Color(0xFFF3F4F6);
  }

  Color _getStatusTextColor(String statusText) {
    final s = statusText.toUpperCase();
    if (s.contains('PENDING')) {
      return const Color(0xFFB06000);
    } else if (s.contains('PROCESS') || s.contains('PROGRESS')) {
      return const Color(0xFF007AFF);
    } else if (s.contains('COMPLETE') ||
        s.contains('APPROVED') ||
        s.contains('DONE') ||
        s.contains('ACTIVE')) {
      return const Color(0xFF29B000);
    } else if (s.contains('CANCEL') || s.contains('REJECT')) {
      return const Color(0xFFFF3B28);
    }
    return AppColors.instance.textColor;
  }

  Color _getStatusBorderColor(String statusText) {
    final s = statusText.toUpperCase();
    if (s.contains('PENDING')) {
      return const Color(0xFFB06000).withValues(alpha: 0.3);
    } else if (s.contains('PROCESS') || s.contains('PROGRESS')) {
      return const Color(0xFF007AFF).withValues(alpha: 0.3);
    } else if (s.contains('COMPLETE') ||
        s.contains('APPROVED') ||
        s.contains('DONE') ||
        s.contains('ACTIVE')) {
      return const Color(0xFF29B000).withValues(alpha: 0.3);
    } else if (s.contains('CANCEL') || s.contains('REJECT')) {
      return const Color(0xFFFF3B28).withValues(alpha: 0.3);
    }
    return Colors.grey.shade300;
  }


  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ??
        job?.title ??
        job?.homeAsset ??
        "Home Repair Job";
    final effectiveStatus = status ??
        job?.status ??
        "Active";
    final effectivePrice = price ??
        _formatPrice(job?.budgetFee);
    final effectiveAddress = address ?? job?.address;
    final effectiveDescription = description ?? job?.description;
    final effectiveCustomerName = customerName ??
        job?.user?.name ??
        job?.user?.email;
    final rawDate = wishDate ?? job?.wishRepairDate ?? job?.createdAt;
    final effectiveDate = _formatDate(rawDate);
    final effectiveRecurrence = recurrenceType ?? job?.recurrenceType;
    final effectiveUrgency = urgency ?? job?.urgency;
    final effectiveImages = images ?? job?.images ?? [];

    final isEmergency = (effectiveUrgency != null &&
            effectiveUrgency.toUpperCase().contains('EMERGENCY')) ||
        (effectiveRecurrence != null &&
            effectiveRecurrence.toUpperCase().contains('EMERGENCY'));

    final recurrenceLabel = isEmergency
        ? "EMERGENCY"
        : (effectiveRecurrence == 'ANNUAL_INSPECTION'
            ? 'Annual Inspection'
            : (effectiveRecurrence == 'REGULAR'
                ? 'Regular Job'
                : (effectiveRecurrence ?? '')));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.instance.containerBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Recurrence/Urgency Tag & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (recurrenceLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isEmergency
                            ? const Color(0xFFFFECEF)
                            : const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEmergency
                                ? Icons.warning_amber_rounded
                                : Icons.sync_rounded,
                            size: 13,
                            color: isEmergency
                                ? AppColors.instance.error
                                : const Color(0xFFE58A00),
                          ),
                          const Gap(width: 4),
                          AppText(
                            text: recurrenceLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEmergency
                                ? AppColors.instance.error
                                : const Color(0xFFE58A00),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Status Badge with dot
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(effectiveStatus),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusBorderColor(effectiveStatus),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _getStatusTextColor(effectiveStatus),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(width: 6),
                        AppText(
                          text: effectiveStatus,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(effectiveStatus),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(height: 10),

              // Title & Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      text: effectiveTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.instance.textColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.instance.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      text: effectivePrice,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.instance.primary,
                    ),
                  ),
                ],
              ),
              const Gap(height: 12),

              // Customer / Poster Info
              if (effectiveCustomerName != null &&
                  effectiveCustomerName.isNotEmpty) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          AppColors.instance.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.instance.primary,
                      ),
                    ),
                    const Gap(width: 8),
                    Expanded(
                      child: AppText(
                        text: effectiveCustomerName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.instance.textColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (effectiveDate.isNotEmpty) ...[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.instance.gray500,
                      ),
                      const Gap(width: 4),
                      AppText(
                        text: effectiveDate,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray500,
                      ),
                    ],
                  ],
                ),
                const Gap(height: 8),
              ],

              // Address Row
              if (effectiveAddress != null && effectiveAddress.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.instance.gray500,
                      ),
                    ),
                    const Gap(width: 6),
                    Expanded(
                      child: AppText(
                        text: effectiveAddress,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray500,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 8),
              ],

              // Description
              if (effectiveDescription != null &&
                  effectiveDescription.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    text: effectiveDescription,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.textColor.withValues(alpha: 0.8),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(height: 10),
              ],

              // Images preview thumbnails if available
              if (effectiveImages.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      effectiveImages.length.clamp(0, 3),
                      (idx) {
                        return Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 8),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.8,
                            ),
                          ),
                          child: AppImage(
                            url: effectiveImages[idx],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Gap(height: 12),
              ],

              // Divider
              Divider(
                color: Colors.grey.shade300.withValues(alpha: 0.6),
                height: 16,
                thickness: 0.8,
              ),
              const Gap(height: 8),

              // Bottom Button: "Send Quotation"
              AppButton(
                onTap: () {
                  AppSnackBar.instance.success("You need to login as a Technician");
                },
                title: "Send Quotation",
                height: 44,
                backgroundColor: AppColors.instance.primary,
                titleColor: AppColors.instance.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
