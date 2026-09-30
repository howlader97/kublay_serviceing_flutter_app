import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/professional_by_category_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/technician_list/provider/technician_list_provider.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/buttons/detail_row.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/dialogs/login_required_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:belwork/utils/languages/app_translator.dart';
import 'package:belwork/utils/languages/language_provider.dart';

class TechnicianList extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? lat;
  final String? lng;
  final String? radiusKm;
  final String? category;

  const TechnicianList({
    super.key,
    this.categoryId,
    this.lat,
    this.lng,
    this.radiusKm,
    this.category,
  });

  @override
  ConsumerState<TechnicianList> createState() => _TechnicianListState();
}

class _TechnicianListState extends ConsumerState<TechnicianList> {
  final TextEditingController _searchController = TextEditingController();

  static const String _defaultImage =
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lat != null &&
          widget.lat!.isNotEmpty &&
          widget.lng != null &&
          widget.lng!.isNotEmpty) {
        ref.read(technicianListProvider.notifier).fetchNearestProfessionals(
              lat: widget.lat!,
              lng: widget.lng!,
              radiusKm: widget.radiusKm?.isNotEmpty == true
                  ? widget.radiusKm!
                  : '10',
              category: widget.category ?? widget.categoryId ?? '',
            );
      } else {
        ref
            .read(technicianListProvider.notifier)
            .fetchProfessionals(widget.categoryId);
      }
    });

    _searchController.addListener(() {
      ref
          .read(technicianListProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(technicianListProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Gap(height: 16),
              _buildSearchBar(context),
              const Gap(height: 16),

              if (state.isLoading)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) => _buildShimmerCard(),
                )
              else if (state.filteredProfessionals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.engineering_outlined,
                          size: 56,
                          color: AppColors.instance.gray500,
                        ),
                        const Gap(height: 12),
                        AppText(
                          text: 'No technicians found',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.instance.gray500,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredProfessionals.length,
                  itemBuilder: (context, index) {
                    final item = state.filteredProfessionals[index];
                    return _buildTechnicianCard(context, item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        BackButtonWidget(
          onTap: () {
            AppRoutes.instance.pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
        const Gap(width: 14),
        AppText(
          text: 'Artisan/Technician',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.instance.textColor,
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final selectedLanguage = ref.watch(languageProvider);
    const hint = 'Search by name, Service category';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.instance.gray500, size: 22),
          const Gap(width: 10),
          Expanded(
            child: FutureBuilder<String>(
              key: ValueKey('${hint}_$selectedLanguage'),
              future: AppTranslator.translate(hint, selectedLanguage),
              builder: (context, snapshot) {
                final translatedHint = snapshot.data ?? hint;
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: translatedHint,
                    hintStyle: TextStyle(
                      color: AppColors.instance.gray500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(
    BuildContext context,
    ProfessionalByCategoryItem item,
  ) {
    final avatarUrl =
        (item.user?.avatar != null && item.user!.avatar!.isNotEmpty)
            ? item.user!.avatar!
            : _defaultImage;
    final name = item.user?.name ?? 'Unknown';
    final rating = item.user?.rating != null
        ? item.user!.rating.toString()
        : '0.0';
    final isVerified = item.verified == true;
    final hourlyRate = item.hourlyRate != null ? '€${item.hourlyRate}' : '—';
    final categoryName = item.type ?? 'General';
    final responseTime = item.availability ?? '24/7';
    final distance = (item.workingRadiusKmLatitude != null &&
            item.workingRadiusKmLatitude!.isNotEmpty)
        ? '${item.workingRadiusKmLatitude}km'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AppImage(
              url: avatarUrl,
              height: 166,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: AppText(
                              text: name,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.instance.textColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const Gap(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF2196F3),
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Gap(width: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFBE00),
                          size: 16,
                        ),
                        const Gap(width: 4),
                        AppText(
                          text: rating,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.instance.textColor,
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(height: 8),
                DetailRow(label: 'Category', value: categoryName),
                DetailRow(label: 'Distance', value: distance),
                DetailRow(label: 'Hourly rate', value: hourlyRate),
                DetailRow(label: 'Response time', value: responseTime),
                const Gap(height: 14),
                AppButton(
                  title: 'Chat',
                  height: 42,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  onTap: () async {
                    final token = await StorageServices.instance.getToken();
                    if (token.trim().isEmpty) {
                      if (context.mounted) {
                        showLoginRequiredDialog(
                          context,
                          message: "You need to log in to chat with technicians.",
                        );
                      }
                      return;
                    }

                    final targetUserId = item.userId ?? item.user?.id;
                    if (targetUserId == null || targetUserId.isEmpty) {
                      AppSnackBar.instance.error("User information not available");
                      return;
                    }

                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.chatScreen,
                      extra: ChatUserModel(
                        id: targetUserId,
                        name: item.user?.name ?? 'Technician',
                        avatar: item.user?.avatar ?? '',
                        jobId: null,
                      ),
                    );
                  },
                ),
                const Gap(height: 8),
                AppButton(
                  title: 'View Profile',
                  height: 42,
                  backgroundColor: Colors.transparent,
                  borderColor: AppColors.instance.primary,
                  titleColor: AppColors.instance.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  onTap: () {
                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.customerToTechnicianProfile,
                      extra: item.id,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 166,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.instance.gray200.withValues(alpha: 0.4),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 140, height: 16),
                    _shimmerBox(width: 40, height: 16),
                  ],
                ),
                const Gap(height: 12),
                _shimmerBox(width: double.infinity, height: 14),
                const Gap(height: 8),
                _shimmerBox(width: double.infinity, height: 14),
                const Gap(height: 8),
                _shimmerBox(width: double.infinity, height: 14),
                const Gap(height: 8),
                _shimmerBox(width: double.infinity, height: 14),
                const Gap(height: 14),
                _shimmerBox(width: double.infinity, height: 42, radius: 8),
                const Gap(height: 8),
                _shimmerBox(width: double.infinity, height: 42, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 4,
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
