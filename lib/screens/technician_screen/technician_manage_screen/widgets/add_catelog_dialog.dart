import 'dart:io';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/widgets/buttons/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../customer_screen/customer_home_screen/provider/service_category_provider.dart';
import '../provider/technician_manage_provider.dart';

class AddCatalogDialog extends ConsumerStatefulWidget {
  const AddCatalogDialog({super.key});

  @override
  ConsumerState<AddCatalogDialog> createState() => _AddCatalogDialogState();
}

class _AddCatalogDialogState extends ConsumerState<AddCatalogDialog> {
  ServiceCategoryModel? _selectedCategory;
  bool _isEmergency = false;
  final TextEditingController _priceController = TextEditingController();
  String? _selectedImagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildImageItem(String imgPath) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(imgPath),
            width: 65,
            height: 65,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImagePath = null;
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: AppColors.instance.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.add_a_photo_outlined, size: 20, color: AppColors.instance.black50),
            const SizedBox(height: 2),
            AppText(
              text: _selectedImagePath == null ? '0/1' : '1/1',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.instance.textColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_selectedCategory == null || _selectedCategory?.id == null) {
      AppSnackBar.instance.error("Please select a category");
      return;
    }

    final price = _priceController.text.trim();
    if (price.isEmpty) {
      AppSnackBar.instance.error("Please enter a price");
      return;
    }

    if (_selectedImagePath == null || _selectedImagePath!.isEmpty) {
      AppSnackBar.instance.error("Please select an avatar image");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final formattedPriority = _isEmergency ? 'HIGH_URGENCY' : 'LOW_URGENCY';

    final success = await ref
        .read(technicianManageProvider.notifier)
        .createServiceCategory(
          categoryId: _selectedCategory!.id!,
          priorityLevel: formattedPriority,
          price: price,
          avatarPath: _selectedImagePath,
        );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    if (success) {
      AppSnackBar.instance.success("Service category created successfully");
      AppRoutes.instance.pop();
    } else {
      AppSnackBar.instance.error("Failed to create service category");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(serviceCategoryProvider);
    return AlertDialog(
      backgroundColor: AppColors.instance.containerBackground,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  AppRoutes.instance.pop();
                },
                child: Icon(Icons.close, color: AppColors.instance.black),
              ),
            ),
            categoriesAsync.when(
              data: (categories) {
                return DropdownField<ServiceCategoryModel>(
                  title: "Category",
                  hintText: "Select Category",
                  padding: EdgeInsets.zero,
                  value: _selectedCategory,
                  options: categories,
                  itemLabel: (cat) => cat.name ?? '',
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                );
              },
              loading: () => Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    AppText(
                      text: 'Loading categories...',
                      fontSize: 13,
                      color: AppColors.instance.gray500,
                    ),
                  ],
                ),
              ),
              error: (err, stack) => AppText(
                text: 'Failed to load categories',
                fontSize: 12,
                color: AppColors.instance.red73,
              ),
            ),
            const Gap(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEmergency = !_isEmergency;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: _isEmergency ? AppColors.instance.primary: AppColors.instance.containerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 22,
                            color: _isEmergency ? AppColors.instance.white : AppColors.instance.textColor,
                          ),
                          const SizedBox(width: 10),
                          AppText(
                            text: 'Emergency',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isEmergency ? AppColors.instance.white : AppColors.instance.textColor,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isEmergency,
                      onChanged: (value) {
                        setState(() {
                          _isEmergency = value;
                        });
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF7A122E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor:
                      Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(height: 10),
            AppInputWidgetTwo(
              controller: _priceController,
              keyboardType: TextInputType.number,
              fillColor: AppColors.instance.white,
              borderColor: AppColors.instance.white,
              hintText: "65",
              title: "Price (€)",
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            const Gap(height: 14),
            AppText(
              text: "Avatar Image",
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.instance.textColor,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedImagePath != null &&
                      _selectedImagePath!.isNotEmpty)
                    _buildImageItem(_selectedImagePath!),
                  if (_selectedImagePath == null ||
                      _selectedImagePath!.isEmpty)
                    _buildAddImageButton(),
                ],
              ),
            ),
            const Gap(height: 20),
            AppButton(
              title: "Save Categories",
              height: 44,
              isLoading: _isSubmitting,
              onTap: _isSubmitting ? null : _onSubmit,
            ),
            const Gap(height: 20),
            AppButton(
              title: "Cancel",
              height: 44,
              backgroundColor: Colors.transparent,
              titleColor: AppColors.instance.textColor,
              onTap: () {
                AppRoutes.instance.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}


