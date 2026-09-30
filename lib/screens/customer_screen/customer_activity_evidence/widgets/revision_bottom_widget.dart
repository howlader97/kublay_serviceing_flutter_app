import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_activity_evidence/provider/job_revision_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';

class RevisionBottomWidget extends ConsumerStatefulWidget {
  final String jobId;

  const RevisionBottomWidget({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<RevisionBottomWidget> createState() =>
      _RevisionBottomWidgetState();
}

class _RevisionBottomWidgetState extends ConsumerState<RevisionBottomWidget> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final note = _noteController.text.trim();

    final success =
        await ref.read(jobRevisionProvider.notifier).submitRevision(
              jobId: widget.jobId,
              note: note,
            );

    if (success && mounted) {
      AppRoutes.instance.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final revisionState = ref.watch(jobRevisionProvider);
    final isSubmitting = revisionState.isLoading;

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
            const Gap(height: 12),
            AppInputWidgetTwo(
              controller: _noteController,
              title: "Revision",
              titleColor: AppColors.instance.containerBackground,
              hintText: "Input your revision",
              hintStyle: TextStyle(
                color: AppColors.instance.containerBackground.withValues(alpha: 0.7),
              ),
              maxLines: 3,
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
