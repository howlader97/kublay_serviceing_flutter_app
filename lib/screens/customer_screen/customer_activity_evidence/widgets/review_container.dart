import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_activity_evidence/provider/job_feedback_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import '../customer_activity_evidence.dart';

class ReviewContainer extends ConsumerStatefulWidget {
  final String jobId;
  final String userId;
  final String professionalId;

  const ReviewContainer({
    super.key,
    required this.jobId,
    required this.userId,
    required this.professionalId,
  });

  @override
  ConsumerState<ReviewContainer> createState() => _ReviewContainerState();
}

class _ReviewContainerState extends ConsumerState<ReviewContainer> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final rating = ref.read(ratingProvider);
    final note = _noteController.text.trim();

    final success =
        await ref.read(jobFeedbackProvider.notifier).submitFeedback(
              jobId: widget.jobId,
              rating: rating,
              userId: widget.userId,
              professionalId: widget.professionalId,
              note: note,
            );

    if (success && mounted) {
      ref.read(ratingProvider.notifier).state = -1;
      AppRoutes.instance.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(jobFeedbackProvider);
    final isSubmitting = feedbackState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.instance.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                AppRoutes.instance.pop();
              },
              child: Icon(
                Icons.close,
                color: AppColors.instance.containerBackground,
              ),
            ),
            const Gap(height: 8),
            AppText(
              text: "Tap the stars to rate this Contractor",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.instance.containerBackground,
            ),
            const Gap(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final rating = ref.watch(ratingProvider);
                return Row(
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () {
                        ref.read(ratingProvider.notifier).state = index + 1;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Icon(
                          index < rating
                              ? Icons.star
                              : Icons.star_border_outlined,
                          size: 32,
                          color: index < rating
                              ? Colors.amber
                              : AppColors.instance.containerBackground,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Gap(height: 12),
            AppInputWidgetTwo(
              controller: _noteController,
              title: "Write Something",
              maxLines: 3,
              textColor: AppColors.instance.containerBackground,
              titleColor: AppColors.instance.containerBackground,
              hintText: "Input your review",
              hintStyle: TextStyle(
                color: AppColors.instance.containerBackground.withValues(alpha: 0.7),
              ),
            ),
            const Gap(height: 14),
            AppButton(
              onTap: isSubmitting ? null : _onSubmit,
              title: isSubmitting ? "Submitting..." : "Submit",
              backgroundColor: isSubmitting
                  ? AppColors.instance.gray500
                  : AppColors.instance.gray4B,
              height: 50,
            ),
            const Gap(height: 20),
          ],
        ),
      ),
    );
  }
}
