import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/technician_job_response.dart';

class CustomerReviewItem {
  final String name;
  final String avatarUrl;
  final int rating;
  final String timestamp;
  final String comment;

  const CustomerReviewItem({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.timestamp,
    required this.comment,
  });
}

class TechnicianQuotationToCustomerScreen extends StatelessWidget {
  final TechnicianJobItem? jobItem;
  final List<CustomerReviewItem>? reviews;

  const TechnicianQuotationToCustomerScreen({
    super.key,
    this.jobItem,
    this.reviews,
  });

  String _buildJobDetailsText() {
    if (jobItem == null) {
      return "No job details available.";
    }

    final List<String> details = [];

    if (jobItem?.title != null && jobItem!.title!.isNotEmpty) {
      details.add("Job: ${jobItem!.title}");
    } else if (jobItem?.homeAsset != null && jobItem!.homeAsset!.isNotEmpty) {
      details.add("Asset: ${jobItem!.homeAsset}");
    }

    if (jobItem?.description != null && jobItem!.description!.isNotEmpty) {
      details.add(jobItem!.description!);
    }

    if (jobItem?.region != null && jobItem!.region!.isNotEmpty) {
      details.add("Location: ${jobItem!.region}");
    } else if (jobItem?.address != null && jobItem!.address!.isNotEmpty) {
      details.add("Address: ${jobItem!.address}");
    }

    if (jobItem?.wishRepairDate != null &&
        jobItem!.wishRepairDate!.isNotEmpty) {
      details.add("Preferred Date: ${jobItem!.wishRepairDate}");
    }

    if (details.isEmpty) {
      return "No details provided for this opportunity.";
    }

    return details.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        (jobItem?.user?.avatar != null && jobItem!.user!.avatar!.isNotEmpty)
        ? jobItem!.user!.avatar!
        : "https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768";

    final customerName =
        (jobItem?.user?.name != null && jobItem!.user!.name!.isNotEmpty)
        ? jobItem!.user!.name!
        : ((jobItem?.user?.email != null && jobItem!.user!.email!.isNotEmpty)
              ? jobItem!.user!.email!
              : "Customer");

    final reviewsList = reviews ?? [];

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Back Button
              Row(
                children: [
                  BackButtonWidget(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Gap(width: 14),
                  AppText(
                    text: "Customer",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.instance.textColor,
                  ),
                ],
              ),
              const Gap(height: 15),

              Center(
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: AppImage(
                          url: avatarUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Gap(height: 14),

                    // Name and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: customerName,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.instance.textColor14,
                        ),
                        const Gap(width: 8),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 20,
                        ),
                        const Gap(width: 4),
                        AppText(
                          text: "0",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.instance.textColor,
                        ),
                        const Gap(width: 4),
                        AppText(
                          text: "(80)",
                          fontSize: 14,
                          color: AppColors.instance.gray4B,
                        ),
                      ],
                    ),
                    const Gap(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Take services: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.instance.gray4B,
                            ),
                          ),
                          TextSpan(
                            text: "10+",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.instance.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppText(
                        text: _buildJobDetailsText(),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.textColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Gap(height: 20),

                    AppButton(
                      onTap: () {
                        final targetUserId =
                            jobItem?.userId ?? jobItem?.id ?? '';
                        AppRoutes.instance.pushNamed(
                          AppRoutesKey.instance.chatScreen,
                          extra: ChatUserModel(
                            id: targetUserId,
                            name: customerName,
                            avatar: avatarUrl,
                            jobId: jobItem?.id,
                          ),
                        );
                      },
                      title: "Chat & Send Quotation",
                      backgroundColor: AppColors.instance.primary,
                      titleColor: AppColors.instance.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ],
                ),
              ),
              if (reviewsList.isNotEmpty) ...[
                const Gap(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewsList.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      color: AppColors.instance.gray50.withValues(alpha: 0.3),
                      height: 1,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final review = reviewsList[index];
                    return _buildReviewItem(review);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(CustomerReviewItem review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer Header Row
        Row(
          children: [
            ClipOval(
              child: AppImage(
                url: review.avatarUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: review.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                  const Gap(height: 2),
                  Row(
                    children: List.generate(
                      review.rating,
                      (index) => const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(height: 8),

        AppText(
          text: review.timestamp,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.instance.textColor,
        ),
        const Gap(height: 6),

        // Review Text
        AppText(
          text: review.comment,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.instance.gray4B,
        ),
      ],
    );
  }
}
