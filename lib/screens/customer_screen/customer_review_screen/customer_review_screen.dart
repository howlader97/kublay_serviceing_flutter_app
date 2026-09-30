import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/services/repository/professional_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerReviewScreen extends ConsumerStatefulWidget {
  final String? customProfessionalId;

  const CustomerReviewScreen({super.key, this.customProfessionalId});

  @override
  ConsumerState<CustomerReviewScreen> createState() =>
      _CustomerReviewScreenState();
}

class _CustomerReviewScreenState
    extends ConsumerState<CustomerReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(technicianProfileProvider.notifier)
          .fetchProfileDetails(showLoading: false);
    });
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        final local = parsed.toLocal();
        final now = DateTime.now();
        final isToday = local.year == now.year &&
            local.month == now.month &&
            local.day == now.day;
        final isYesterday = local.year == now.year &&
            local.month == now.month &&
            local.day == now.day - 1;
        final hour = local.hour.toString().padLeft(2, '0');
        final minute = local.minute.toString().padLeft(2, '0');
        if (isToday) return 'Today, $hour:$minute';
        if (isYesterday) return 'Yesterday, $hour:$minute';
        return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}, $hour:$minute';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(technicianProfileProvider);
    final reviews = profileState.profileDetails?.data?.allReviews ?? [];
    final isLoading = profileState.isLoading && reviews.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.maybePop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppText(
                      text: "Review",
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.instance.black07),
                  // const Spacer(),
                  // // Appeal Status Button
                  // GestureDetector(
                  //   onTap: () {
                  //     AppRoutes.instance
                  //         .pushNamed(AppRoutesKey.instance.customerAppealStatus);
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 14, vertical: 10),
                  //     decoration: BoxDecoration(
                  //         color: AppColors.instance.primary,
                  //         borderRadius: BorderRadius.circular(8)),
                  //     child: const AppText(
                  //         text: "Appeal Status",
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Reviews List / Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(technicianProfileProvider.notifier)
                            .fetchProfileDetails(showLoading: false);
                      },
                      child: reviews.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rate_review_outlined,
                                            size: 56,
                                            color: AppColors.instance.gray400),
                                        const Gap(height: 12),
                                        AppText(
                                          text: "No reviews found yet",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.instance.gray500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 16.0),
                              itemCount: reviews.length,
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child:
                                    Divider(height: 1, color: Color(0xFFE5E5E5)),
                              ),
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                return _ReviewCardItem(
                                  review: review,
                                  formattedDate:
                                      _formatDateTime(review.createdAt),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCardItem extends StatefulWidget {
  final ReviewData review;
  final String formattedDate;

  const _ReviewCardItem({
    required this.review,
    required this.formattedDate,
  });

  @override
  State<_ReviewCardItem> createState() => _ReviewCardItemState();
}

class _ReviewCardItemState extends State<_ReviewCardItem> {
 // final GlobalKey _threeDotsKey = GlobalKey();

  // void _showAppealDropdown(BuildContext context) {
  //   RenderBox renderBox =
  //       _threeDotsKey.currentContext!.findRenderObject() as RenderBox;
  //   Offset offset = renderBox.localToGlobal(Offset.zero);
  //   Size size = renderBox.size;
  //
  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierLabel: "AppealDropdown",
  //     barrierColor: Colors.black.withValues(alpha: 0.2),
  //     transitionDuration: const Duration(milliseconds: 200),
  //     pageBuilder: (context, anim1, anim2) {
  //       return _AppealDropdownDialog(
  //         targetOffset: offset,
  //         targetSize: size,
  //         review: widget.review,
  //       );
  //     },
  //     transitionBuilder: (context, anim1, anim2, child) {
  //       return FadeTransition(
  //         opacity: anim1,
  //         child: ScaleTransition(
  //             scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
  //             alignment: Alignment.topRight,
  //             child: child),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final ratingValue = widget.review.rating?.toInt() ?? 5;
    final userName = (widget.review.userName != null &&
            widget.review.userName!.isNotEmpty)
        ? widget.review.userName!
        : 'Customer';
    final userAvatar = widget.review.userAvatar;
    final note = widget.review.note ?? '';
    final images = widget.review.images ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFFE3D1),
              child: ClipOval(
                child: (userAvatar != null && userAvatar.isNotEmpty)
                    ? Image.network(
                        userAvatar,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person,
                              color: AppColors.instance.primary, size: 28);
                        },
                      )
                    : Icon(Icons.person,
                        color: AppColors.instance.primary, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                      text: userName,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.instance.black07),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (starIndex) => Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Icon(
                          Icons.star_rounded,
                          color: starIndex < ratingValue
                              ? const Color(0xFFFFC107)
                              : Colors.grey.shade300,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3-Dots Action Button
            // IconButton(
            //   key: _threeDotsKey,
            //   onPressed: () => _showAppealDropdown(context),
            //   icon: const Icon(Icons.more_vert, color: Colors.black87),
            //   padding: EdgeInsets.zero,
            //   constraints: const BoxConstraints(),
            // ),
          ],
        ),
        const SizedBox(height: 8),

        // Date Time
        AppText(
            text: widget.formattedDate,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.instance.black300),
        const SizedBox(height: 8),

        if (note.isNotEmpty)
          Text(
            note,
            style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.instance.black07,
                fontWeight: FontWeight.w400),
          ),

        if (images.isNotEmpty) ...[
          const Gap(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, imgIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[imgIndex],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, err, stack) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _AppealDropdownDialog extends StatefulWidget {
  final Offset targetOffset;
  final Size targetSize;
  final ReviewData review;

  const _AppealDropdownDialog({
    required this.targetOffset,
    required this.targetSize,
    required this.review,
  });

  @override
  State<_AppealDropdownDialog> createState() => _AppealDropdownDialogState();
}

class _AppealDropdownDialogState extends State<_AppealDropdownDialog> {
  final List<String> _reasons = const [
    "False Review",
    "Abuse",
    "Off Topic",
    "Misleading",
    "Policy Violation",
    "Spam",
    "Mistake",
    "Other"
  ];

  String _selectedReason = "Other";
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final String comment = _commentController.text.trim();
    final String reason = _selectedReason.toUpperCase().replaceAll(' ', '_');
    final String jobId = widget.review.jobId ?? '';
    final String reviewId = widget.review.id ?? '';
    final String reportedId = widget.review.userId ?? '';

    // Reporter is the logged-in professional
    final professionalId = (widget.review.professionalId != null &&
            widget.review.professionalId!.isNotEmpty)
        ? widget.review.professionalId!
        : await StorageServices.instance.getProfessionalId();

    if (jobId.isEmpty || reviewId.isEmpty) {
      AppSnackBar.instance.error("Missing Job ID or Review ID for report.");
      return;
    }

    if (reportedId.isEmpty) {
      AppSnackBar.instance.error("Missing Customer ID for report.");
      return;
    }

    if (professionalId.isEmpty) {
      AppSnackBar.instance.error("Professional ID not found.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final isSuccess = await ProfessionalRepository.instance.submitReport(
      jobId: jobId,
      reviewId: reviewId,
      reporterId: professionalId,
      reportedId: reportedId,
      reason: reason,
      comment: comment,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (isSuccess) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    double top = widget.targetOffset.dy + widget.targetSize.height + 4;
    if (top + 420 > mediaQuery.size.height) {
      top = mediaQuery.size.height - 440;
    }
    double right = 16.0;

    return Stack(
      children: [
        Positioned(
          top: top < 40 ? 40 : top,
          right: right,
          width: mediaQuery.size.width * 0.75 > 320
              ? 320
              : mediaQuery.size.width * 0.75,
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._reasons.map((reason) {
                      final isSelected = _selectedReason == reason;
                      return InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _selectedReason = reason;
                                });
                              },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.instance.green59
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: AppColors.instance.green59,
                                      width: 1.5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  text: reason,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: AppColors.instance.black07,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const Gap(height: 12),
                    TextField(
                      controller: _commentController,
                      enabled: !_isSubmitting,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "enter your comment",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 13),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFCCCCCC))),
                      ),
                    ),
                    const Gap(height: 16),
                    AppButton(
                      isLoading: _isSubmitting,
                      onTap: _handleSubmit,
                      height: 42,
                      width: 100,
                      borderRadius: BorderRadius.circular(8),
                      title: "Submit",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
