import 'dart:io';
import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:belwork/services/repository/professional_repository.dart';
import 'package:belwork/utils/app_snack_bar.dart';


class TechnicianSubmitEvidence extends StatefulWidget {
  final String? jobId;

  const TechnicianSubmitEvidence({super.key, this.jobId});

  @override
  State<TechnicianSubmitEvidence> createState() => _TechnicianSubmitEvidenceState();
}

class _TechnicianSubmitEvidenceState extends State<TechnicianSubmitEvidence> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<File> _pickedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_pickedImages.length >= 3) {
      AppSnackBar.instance.error("Maximum 3 images allowed.");
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImages.add(File(image.path));
      });
    }
  }

  Future<void> _submitEvidence() async {
    final note = _noteController.text.trim();
    final summary = _summaryController.text.trim();

    if (widget.jobId == null || widget.jobId!.isEmpty) {
      AppSnackBar.instance.error("Job ID is missing.");
      return;
    }

    if (note.isEmpty) {
      AppSnackBar.instance.error("Please enter a note.");
      return;
    }

    if (summary.isEmpty) {
      AppSnackBar.instance.error("Please enter a summary.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ProfessionalRepository.instance.postTaskEvidence(
      jobId: widget.jobId!,
      summary: summary,
      note: note,
      imageFiles: _pickedImages,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        AppRoutes.instance.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top AppBar header row
                Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    const Gap(width: 16),
                    AppText(text: "Task evidence", fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  ],
                ),
                const Gap(height: 8),

                AppInputWidgetTwo(
                  title: "Note",
                  controller: _noteController,
                  hintText: "Everything is in order. No issue",
                ),
                AppInputWidgetTwo(
                  title: "Summary",
                  controller: _summaryController,
                  hintText: "What happened?",
                  maxLines: 4,
                ),
                const Gap(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: "Photos (Max 3)",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.textColor,
                    ),
                    AppText(
                      text: "${_pickedImages.length}/3",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.instance.gray500,
                    ),
                  ],
                ),
                const Gap(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._pickedImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return _buildPhotoItem(
                          imageWidget: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
                          onRemove: () {
                            setState(() {
                              _pickedImages.removeAt(index);
                            });
                          },
                        );
                      }),

                      if (_pickedImages.length < 3)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.instance.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.instance.gray300, style: BorderStyle.solid, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 22, color: AppColors.instance.textColor),
                                const Gap(height: 2),
                                AppText(text: "Add", fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.instance.textColor),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Gap(height: 32),

                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.instance.primary,
                        ),
                      )
                    : AppButton(
                        onTap: _submitEvidence,
                        title: "Submit Evidence",
                        backgroundColor: AppColors.instance.primary,
                        titleColor: AppColors.instance.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                const Gap(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem({required Widget imageWidget, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: imageWidget),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
