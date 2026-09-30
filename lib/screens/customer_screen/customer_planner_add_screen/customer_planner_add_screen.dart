import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/provider/service_category_provider.dart';
import 'package:belwork/screens/customer_screen/customer_planner_add_screen/provider/create_job_provider.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/provider/yearly_inspection_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/utils/languages/app_translator.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/drop_down.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:image_picker/image_picker.dart';

class CustomerPlannerAddScreen extends ConsumerStatefulWidget {
  const CustomerPlannerAddScreen({super.key});

  @override
  ConsumerState<CustomerPlannerAddScreen> createState() =>
      _CustomerPlannerAddScreenState();
}

class _CustomerPlannerAddScreenState
    extends ConsumerState<CustomerPlannerAddScreen> {
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _constructionYearsController =
      TextEditingController();
  final TextEditingController _budgetFeeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedWishRepairDate;
  bool _isEmergency = false;
  ServiceCategoryModel? _selectedCategory;
  String? _selectedRecurrenceType = 'ANNUAL_INSPECTION';
  String? _selectedRegion = 'BRUSSELS';

  final List<String> _recurrenceTypes = [
    'REGULAR',
    'ANNUAL_INSPECTION',
  ];

  final List<String> _regions = ['BRUSSELS', 'WALLONIA', 'FLANDERS'];

  final List<String> _selectedImages = [];
  bool _isAddressPreFilled = false;

  @override
  void dispose() {
    _assetNameController.dispose();
    _constructionYearsController.dispose();
    _budgetFeeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      AppSnackBar.instance.error("Maximum 3 images allowed");
      return;
    }
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
          _selectedImages.add(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectWishRepairDate(BuildContext context) async {
    final selectedLanguage = ref.read(languageProvider);
    final langParts = selectedLanguage.split('_');
    final langCode = langParts[0].toLowerCase();
    final countryCode = langParts.length > 1 ? langParts[1] : null;

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(langCode, countryCode),
      initialDate:
          _selectedWishRepairDate ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText:
          AppTranslator.localTrans("Select date", selectedLanguage) ??
          "Select date",
      cancelText:
          AppTranslator.localTrans("Cancel", selectedLanguage) ?? "Cancel",
      confirmText: AppTranslator.localTrans("OK", selectedLanguage) ?? "OK",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.instance.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.instance.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedWishRepairDate = picked;
      });
    }
  }

  void _onSubmitJob() async {
    final title = _assetNameController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.instance.error("Please enter home asset / title");
      return;
    }

    if (_selectedWishRepairDate == null) {
      AppSnackBar.instance.error("Please select wish repair date");
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.id == null) {
      AppSnackBar.instance.error("Please select category");
      return;
    }

    final constructionYears = _constructionYearsController.text.trim();

    if (_selectedRegion == null || _selectedRegion!.isEmpty) {
      AppSnackBar.instance.error("Please select region");
      return;
    }

    if (_selectedRecurrenceType == null) {
      AppSnackBar.instance.error("Please select recurrence type");
      return;
    }

    final budgetFee = _budgetFeeController.text.trim();
    if (budgetFee.isEmpty) {
      AppSnackBar.instance.error("Please enter budget fee");
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      AppSnackBar.instance.error("Please enter address");
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppSnackBar.instance.error("Please enter description");
      return;
    }

    final userProfileAsync = ref.read(userProfileProvider);
    final user = userProfileAsync.asData?.value;
    final userId = user?.id;

    if (userId == null || userId.isEmpty) {
      AppSnackBar.instance.error("User session invalid. Please log in again.");
      return;
    }

    // Format wishRepairDate as ISO 8601 UTC string for backend
    final wishRepairDateStr = DateTime.utc(
      _selectedWishRepairDate!.year,
      _selectedWishRepairDate!.month,
      _selectedWishRepairDate!.day,
    ).toIso8601String();

    final success = await ref
        .read(createJobProvider.notifier)
        .submitJob(
          userId: userId,
          categoryId: _selectedCategory!.id!,
          title: title,
          description: description,
          constructionYears: constructionYears.isNotEmpty
              ? constructionYears
              : null,
          region: _selectedRegion!,
          homeAsset: title,
          recurrenceType: _selectedRecurrenceType!,
          wishRepairDate: wishRepairDateStr,
          budgetFee: budgetFee,
          address: address,
          latitude: user?.latitude?.toString() ?? '',
          longitude: user?.longitude?.toString() ?? '',
          imagePaths: _selectedImages,
          urgency: _isEmergency ? 'HIGH_URGENCY' : 'LOW_URGENCY',
        );

    if (success && mounted) {
      ref.read(yearlyInspectionProvider.notifier).fetchYearlyInspections();
      Navigator.of(context).pop(true);
    }
  }

  String _formatDropdownText(String text) {
    if (text.isEmpty) return text;
    return text
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  Widget _buildLabel(String title, {String? optional}) {
    return Row(
      children: [
        AppText(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.instance.textColor,
        ),
        if (optional != null) ...[
          const SizedBox(width: 4),
          AppText(
            text: optional,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.instance.gray500,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String selectedLanguage,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final targetLang = selectedLanguage.split('_')[0].toLowerCase();
    if (targetLang == 'en' || hintText.trim().isEmpty) {
      return TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14, color: AppColors.instance.textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.instance.gray500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.instance.primary,
              width: 1.2,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<String>(
      key: ValueKey("hint_${hintText}_$selectedLanguage"),
      future: AppTranslator.translate(hintText, selectedLanguage),
      builder: (context, snapshot) {
        final hint = snapshot.data ?? hintText;
        return TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: AppColors.instance.textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.instance.gray500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.instance.primary,
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageItem(String imgPath, int index) {
    final isNetwork = imgPath.startsWith('http');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 70,
            height: 70,
            color: Colors.grey.shade200,
            child: isNetwork
                ? AppImage(
                    url: imgPath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : AppImage(
                    filePath: imgPath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.black87),
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade400,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 22, color: Colors.black87),
            const SizedBox(height: 2),
            AppText(
              text: 'Add (${_selectedImages.length}/3)',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.instance.textColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(languageProvider);
    final categoriesAsync = ref.watch(serviceCategoryProvider);
    final createJobState = ref.watch(createJobProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final isSubmitting = createJobState.isLoading;

    // Auto pre-fill address from user profile if available
    if (!_isAddressPreFilled && userProfileAsync.hasValue) {
      final profileAddress = userProfileAsync.value?.address;
      if (profileAddress != null && profileAddress.isNotEmpty) {
        _addressController.text = profileAddress;
        _isAddressPreFilled = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: 'Add new asset',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.instance.textColor,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE8EC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFE57373),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(height: 18),

                    // Add home asset input
                    _buildLabel('Add home asset'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _assetNameController,
                      hintText: 'Asset Name',
                      selectedLanguage: selectedLanguage,
                    ),
                    const Gap(height: 14),

                    // Wish Repair Date Picker Field
                    _buildLabel('Wish Repair Date'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _selectWishRepairDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: _selectedWishRepairDate != null
                                  ? "${_selectedWishRepairDate!.day.toString().padLeft(2, '0')}/${_selectedWishRepairDate!.month.toString().padLeft(2, '0')}/${_selectedWishRepairDate!.year}"
                                  : "Select Repair Date",
                              fontSize: 14,
                              color: _selectedWishRepairDate != null
                                  ? AppColors.instance.textColor
                                  : AppColors.instance.gray500,
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(height: 14),

                    // Category Dropdown using reusable DropdownField
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
                    const Gap(height: 14),

                    // Emergency Urgency Banner
                    _buildLabel('Urgency'),
                    const SizedBox(height: 6),
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
                          vertical: 6,
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
                    const Gap(height: 14),

                    // Construction Years
                    _buildLabel('Construction Years', optional: '(optional)'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _constructionYearsController,
                      hintText: 'e.g. 10',
                      selectedLanguage: selectedLanguage,
                      keyboardType: TextInputType.number,
                    ),
                    const Gap(height: 14),

                    // Region Dropdown using reusable DropdownField
                    DropdownField<String>(
                      title: "Region",
                      hintText: "Select Region",
                      padding: EdgeInsets.zero,
                      value: _selectedRegion,
                      options: _regions,
                      itemLabel: _formatDropdownText,
                      onChanged: (val) {
                        setState(() {
                          _selectedRegion = val;
                        });
                      },
                    ),
                    const Gap(height: 14),

                    // Recurrence Type Dropdown
                    DropdownField<String>(
                      title: "Recurrence Type",
                      hintText: "Select Recurrence Type",
                      padding: EdgeInsets.zero,
                      value: _selectedRecurrenceType,
                      options: _recurrenceTypes,
                      itemLabel: _formatDropdownText,
                      onChanged: (val) {
                        setState(() {
                          _selectedRecurrenceType = val;
                        });
                      },
                    ),
                    const Gap(height: 14),

                    // Budget Fee (€)
                    _buildLabel('Budget Fee (€)'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _budgetFeeController,
                      hintText: 'e.g. 100',
                      selectedLanguage: selectedLanguage,
                      keyboardType: TextInputType.number,
                    ),
                    const Gap(height: 14),

                    // Address
                    _buildLabel('Address'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _addressController,
                      hintText: 'Enter address',
                      selectedLanguage: selectedLanguage,
                    ),
                    const Gap(height: 14),

                    // Description Input
                    _buildLabel('Description'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your task',
                      selectedLanguage: selectedLanguage,
                      maxLines: 4,
                    ),
                    const Gap(height: 14),

                    // Asset Images Section (Max 3)
                    _buildLabel('Asset images', optional: '(optional, max 3)'),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < _selectedImages.length; i++) ...[
                            _buildImageItem(_selectedImages[i], i),
                            const Gap(width: 10),
                          ],
                          if (_selectedImages.length < 3) _buildAddImageButton(),
                        ],
                      ),
                    ),
                    const Gap(height: 20),

                    // Register Asset Button
                    AppButton(
                      title: isSubmitting ? 'Registering...' : 'Register Asset',
                      height: 46,
                      backgroundColor: isSubmitting
                          ? AppColors.instance.gray500
                          : AppColors.instance.primary,
                      titleColor: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      onTap: isSubmitting ? null : _onSubmitJob,
                    ),
                    const Gap(height: 10),

                    // Cancel Button
                    AppButton(
                      title: 'Cancel',
                      height: 46,
                      backgroundColor: Colors.white,
                      borderColor: AppColors.instance.primary,
                      titleColor: AppColors.instance.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
