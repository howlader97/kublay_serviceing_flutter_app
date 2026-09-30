import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerViewDetails extends StatefulWidget {
  final ProjectData? project;

  const CustomerViewDetails({super.key, this.project});

  @override
  State<CustomerViewDetails> createState() => _CustomerViewDetailsState();
}

class _CustomerViewDetailsState extends State<CustomerViewDetails> {
  int _currentImageIndex = 0;

  static const String _defaultImage =
      "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600";

  List<String> get _images {
    final list = widget.project?.images;
    if (list != null && list.isNotEmpty) {
      return list;
    }
    return [_defaultImage];
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "—";
    try {
      final dateTime = DateTime.tryParse(isoString);
      if (dateTime != null) {
        final period = dateTime.hour >= 12 ? "PM" : "AM";
        final hour = dateTime.hour > 12
            ? dateTime.hour - 12
            : (dateTime.hour == 0 ? 12 : dateTime.hour);
        final hourStr = hour.toString().padLeft(2, '0');
        final minuteStr = dateTime.minute.toString().padLeft(2, '0');
        final dayStr = dateTime.day.toString().padLeft(2, '0');
        final monthStr = dateTime.month.toString().padLeft(2, '0');
        final yearStr = dateTime.year.toString();
        return "$hourStr:$minuteStr $period ($dayStr/$monthStr/$yearStr)";
      }
    } catch (_) {}
    return isoString;
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final images = _images;
    final currentIdx = _currentImageIndex.clamp(0, images.length - 1);

    final title = (project?.title != null && project!.title!.isNotEmpty)
        ? project.title!
        : "Project Details";
    final description = (project?.description != null &&
            project!.description!.isNotEmpty)
        ? project.description!
        : "No description provided.";
    final status = project?.status ?? "—";
    final recurrenceType = project?.recurrenceType ?? "—";
    final urgency = project?.urgency ?? "—";
    final budget = (project?.budgetFee != null && project!.budgetFee!.isNotEmpty)
        ? "€${project.budgetFee}"
        : "—";
    final address = project?.address ?? "—";
    final region = project?.region ?? "—";
    final time = _formatDate(project?.wishRepairDate ?? project?.createdAt);
    final endTime = _formatDate(project?.updatedAt);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top AppBar Header Row
                Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    const Gap(width: 16),
                    Expanded(
                      child: AppText(
                        text: title,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 16),

                // Main Content Card Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.instance.containerBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel Section
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              images[currentIdx],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 200,
                                width: double.infinity,
                                color: AppColors.instance.gray200,
                                child: const Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          // Left Arrow Navigation (if multiple images)
                          if (images.length > 1)
                            Positioned(
                              left: 12,
                              top: 82,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentImageIndex =
                                        (_currentImageIndex - 1 + images.length) %
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

                          // Right Arrow Navigation (if multiple images)
                          if (images.length > 1)
                            Positioned(
                              right: 12,
                              top: 82,
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

                          // Page Indicator Dots
                          if (images.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    List.generate(images.length, (index) {
                                  final isActive = index == currentIdx;
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: 24,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.instance.primary
                                          : Colors.black
                                              .withValues(alpha: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                      const Gap(height: 20),

                      // Task & Review Details Section
                      _buildDetailItem(
                        label: "Issue name:",
                        value: title,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Descriptions:",
                        value: description,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Time:",
                        value: time,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "End Time:",
                        value: endTime,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Status:",
                        value: status,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Type:",
                        value: recurrenceType,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Urgency:",
                        value: urgency,
                      ),
                      const Gap(height: 8),
                      _buildDetailItem(
                        label: "Budget Fee:",
                        value: budget,
                      ),
                      if (address.isNotEmpty && address != "—") ...[
                        const Gap(height: 8),
                        _buildDetailItem(
                          label: "Address:",
                          value: address,
                        ),
                      ],
                      if (region.isNotEmpty && region != "—") ...[
                        const Gap(height: 8),
                        _buildDetailItem(
                          label: "Region:",
                          value: region,
                        ),
                      ],
                      const Gap(height: 16),
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

  Widget _buildDetailItem({required String label, required String value}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          fontFamily: 'Inter',
          color: AppColors.instance.textColor,
        ),
        children: [
          TextSpan(
            text: "$label ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.instance.textColor,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.instance.gray4B,
            ),
          ),
        ],
      ),
    );
  }
}
