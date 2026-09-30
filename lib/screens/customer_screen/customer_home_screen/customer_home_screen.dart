import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/all_professional_response.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/provider/customer_home_provider.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/provider/service_category_provider.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/widgets/home_categories_container.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/map/leaflet_location_picker_dialog.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/dialogs/login_required_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  bool _isSosExpanded = false;
  bool _isEmergency = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _radiusController =
      TextEditingController(text: '10');
  ServiceCategoryModel? _selectedSosCategory;


  @override
  void initState() {
    super.initState();
    // Fetch the first page on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerHomeProvider.notifier).fetchInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(customerHomeProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(customerHomeProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isSosExpanded
                  ? _buildExpandedSosPanel(context)
                  : _buildSosBanner(context),
              const Gap(height: 24),
              _buildSectionHeader(
                context,
                title: 'Categories',
                actionText: 'See all',
                onActionTap: () {
                  AppRoutes.instance.pushNamed(
                    AppRoutesKey.instance.customerAllService,
                  );
                },
              ),
              const Gap(height: 14),
              _buildCategoriesGrid(),
              const Gap(height: 24),
              const AppText(
                text: 'Recommended artisans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              const Gap(height: 14),
              _buildArtisansList(homeState),
              const Gap(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosBanner(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final token = await StorageServices.instance.getToken();
        if (token.trim().isEmpty) {
          if (context.mounted) {
            showLoginRequiredDialog(
              context,
              message: "You need to log in to use SOS emergency services.",
            );
          }
          return;
        }
        setState(() {
          _isSosExpanded = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.instance.red73,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6565).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.instance.red3c,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AppText(
                text: 'SOS',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AppText(
                text: 'craftsman available 24/7',
                color: AppColors.instance.white50,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSosPanel(BuildContext context) {
    final categoriesAsync = ref.watch(serviceCategoryProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.instance.red73, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.instance.red73.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Select category',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.instance.textColor,
          ),
          const Gap(height: 8),
          categoriesAsync.when(
            data: (categories) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.instance.gray200.withValues(alpha: 0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<ServiceCategoryModel>(

                    initialValue: _selectedSosCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                    hint: AppText(
                      text: 'Select category',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.instance.gray500,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.instance.textColor,
                      size: 20,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    items: categories.map((cat) {
                      return DropdownMenuItem<ServiceCategoryModel>(
                        value: cat,
                        child: AppText(
                          text: cat.name ?? '',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.instance.textColor,
                        ),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      setState(() {
                        _selectedSosCategory = cat;
                      });
                    },
                  ),
                ),
              );
            },
            loading: () => Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.instance.gray200.withValues(alpha: 0.5),
                ),
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
          const Gap(height: 16),
          AppText(
            text: 'Radius (km)',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.instance.textColor,
          ),
          const Gap(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.instance.gray200.withValues(alpha: 0.5),
              ),
            ),
            child: TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.instance.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Enter search radius (e.g. 10)',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.instance.gray500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixText: 'km',
                suffixStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.primary,
                ),
              ),
            ),
          ),
          const Gap(height: 16),
          AppText(
            text: 'Select priority',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.instance.textColor,
          ),
          const Gap(height: 8),
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
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _isEmergency ? AppColors.instance.primary: AppColors.instance.white,
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
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor:
                    Colors.white.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          ),
          const Gap(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSosExpanded = false;
                    });
                  },
                  child: AppButton(
                    title: "Go Back",
                    height: 40,
                    fontSize: 14,
                    backgroundColor: AppColors.instance.transparent,
                    titleColor: AppColors.instance.primary,
                  ),
                ),
              ),
              const Gap(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final token = await StorageServices.instance.getToken();
                    if (token.trim().isEmpty) {
                      if (context.mounted) {
                        showLoginRequiredDialog(
                          context,
                          message: "You need to log in to use SOS emergency services.",
                        );
                      }
                      return;
                    }

                    if (_selectedSosCategory == null ||
                        _selectedSosCategory!.id == null) {
                      AppSnackBar.instance.error("Please select a category");
                      return;
                    }

                    final radius = _radiusController.text.trim().isNotEmpty
                        ? _radiusController.text.trim()
                        : '10';

                    if (!context.mounted) return;
                    final result =
                        await LeafletLocationPickerDialog.show(context);
                    if (result != null) {
                      AppRoutes.instance.pushNamed(
                        AppRoutesKey.instance.technicianList,
                        extra: {
                          'categoryId': _selectedSosCategory!.id,
                          'category': _selectedSosCategory!.id ?? '',
                          'lat': result.latitude.toString(),
                          'lng': result.longitude.toString(),
                          'radiusKm': radius,
                        },
                      );
                    }
                  },
                  child: AppButton(
                    height: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AppText(
                        text: "Location By GPS",
                        color: AppColors.instance.white50,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: title,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.instance.textColor,
        ),
        GestureDetector(
          onTap: onActionTap,
          child: AppText(text: actionText, color: AppColors.instance.primary),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categoriesAsync = ref.watch(serviceCategoryProvider);


    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: AppText(
                text: 'No categories available',
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }
        final displayedCategories = categories.take(4).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.96,
            mainAxisExtent: 164,
          ),
          itemBuilder: (context, index) {
            final category = displayedCategories[index];
            return GestureDetector(
              onTap: () {
                AppRoutes.instance.pushNamed(
                  AppRoutesKey.instance.technicianList,
                  extra: category.id,
                );
              },
              child: HomeCategoriesContainer(category: category),
            );
          },
        );
      },
      loading: () => _buildCategoriesGridShimmer(),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: AppText(
            text: 'Failed to load categories',
            fontSize: 14,
            color: AppColors.instance.red73,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.96,
        mainAxisExtent: 164,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.instance.containerBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.instance.gray200.withValues(alpha: 0.4),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.instance.gray200.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 70,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.instance.gray200.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtisansList(CustomerHomeState homeState) {
    if (homeState.isLoading) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => _buildArtisanShimmer(),
      );
    }

    final verifiedProfessionals = homeState.professionals
        .where((p) => p.verified == true)
        .toList();

    // Empty state
    if (verifiedProfessionals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: AppText(
            text: 'No artisans available',
            fontSize: 14,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: verifiedProfessionals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildArtisanTile(verifiedProfessionals[index]);
          },
        ),
        // Load-more indicator
        if (homeState.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // End of list label
        if (!homeState.hasMore && verifiedProfessionals.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: AppText(
                text: 'No more artisans',
                fontSize: 13,
                color: AppColors.instance.gray500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildArtisanTile(ProfessionalModel professional) {
    const String defaultAvatar =
        'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImageCircular(
            url: (professional.user?.avatar?.isNotEmpty == true)
                ? professional.user!.avatar!
                : defaultAvatar,
            width: 56,
            height: 56,
            borderRadius: 26,
          ),
          const Gap(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        text: professional.user?.name ?? 'Unknown',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (professional.verified == true) ...[
                      const Gap(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF2196F3),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                AppText(
                  text: "Hourly rate: ${professional.hourlyRate ?? 0}",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.instance.gray500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFBE00), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(
                        text: professional.availability ?? 'Available',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppText(
                    text: professional.hourlyRate != null
                        ? '€${professional.hourlyRate}/hr'
                        : '—',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppText(
                    text: professional.type ?? '',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.gray500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // Handle Inquire Quote
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AppText(
                      text: 'Inquire Quote',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanShimmer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _shimmerBox(width: 56, height: 56, radius: 28),
          const Gap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 120, height: 14),
                const SizedBox(height: 8),
                _shimmerBox(width: 80, height: 12),
                const SizedBox(height: 8),
                _shimmerBox(width: 100, height: 12),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _shimmerBox(width: 60, height: 14),
              const SizedBox(height: 8),
              _shimmerBox(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.instance.gray200.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
