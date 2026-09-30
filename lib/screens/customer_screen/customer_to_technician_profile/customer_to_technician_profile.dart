import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_to_technician_profile/provider/customer_to_technician_profile_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/dialogs/login_required_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerToTechnicianProfile extends ConsumerStatefulWidget {
  final String? professionalId;

  const CustomerToTechnicianProfile({super.key, this.professionalId});

  @override
  ConsumerState<CustomerToTechnicianProfile> createState() =>
      _CustomerToTechnicianProfileState();
}

class _CustomerToTechnicianProfileState
    extends ConsumerState<CustomerToTechnicianProfile> {
  int _selectedTab = 0;

  static const String _defaultAvatar =
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400";
  static const String _defaultProjectImage =
      "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400";

  @override
  Widget build(BuildContext context) {
    final profileAsync =
        ref.watch(customerToTechnicianProfileProvider(widget.professionalId));

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (data) {
            if (data == null) {
              return _buildErrorState(context, "Technician not found");
            }
            return _buildContent(context, data);
          },
          loading: () => _buildLoadingState(context),
          error: (error, stack) =>
              _buildErrorState(context, "Failed to load technician details"),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ProfessionalProfileDetailsData data) {
    final professional = data.professional;
    final user = professional?.user;
    final allProjects = data.allProjects ?? [];
    final allReviews = data.allReviews ?? [];
    final allServices = data.allServices ?? [];

    final avatarUrl = (user?.avatar != null && user!.avatar!.isNotEmpty)
        ? user.avatar!
        : _defaultAvatar;
    final name = user?.name ?? "Unknown";
    final rating = user?.rating != null ? "${user!.rating}" : "0.0";
    final reviewCount = allReviews.length;
    final projectsCount = allProjects.length;

    final openHour = (professional?.workingTimeStart != null &&
            professional!.workingTimeStart!.isNotEmpty)
        ? "${professional.workingTimeStart} - ${professional.workingTimeEnd ?? ''}"
        : "8:00 - 16:00";

    final bio = (user?.bio != null && user!.bio!.isNotEmpty)
        ? user.bio!
        : (professional?.type ?? "Professional technician");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BackButtonWidget(
                  onTap: () {
                    AppRoutes.instance.pop();
                  },
                ),
                const Gap(width: 16),
                AppText(
                  text: "Artisan/Technician",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.textColor,
                ),
                const Spacer(),
                GestureDetector(
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

                    final targetUserId = user?.id;
                    if (targetUserId == null || targetUserId.isEmpty) return;
                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.chatScreen,
                      extra: ChatUserModel(
                        id: targetUserId,
                        name: user?.name ?? 'Technician',
                        avatar: user?.avatar ?? '',
                        jobId: null,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.instance.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppImage(
                      path: AppAssertsIconsPath.instance.chatIcon,
                      height: 22,
                      iconColor: Colors.white,

                    ),
                  ),
                ),
              ],
            ),
            const Gap(height: 10),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.instance.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: AppColors.instance.gray200,
                    ),
                  ),
                  const Gap(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AppText(
                          text: name,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.instance.textColor14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(width: 8),
                      const Icon(Icons.star,
                          color: Color(0xFFFFBE00), size: 18),
                      const Gap(width: 4),
                      AppText(
                        text: rating,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.gray4B,
                      ),
                      AppText(
                        text: " ($reviewCount)",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray4B,
                      ),
                    ],
                  ),
                  const Gap(height: 8),
                  if (professional?.availability != null &&
                      professional!.availability!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AppText(
                        text: "Availability: ${professional.availability}",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray4B,
                      ),
                    ),
                  AppText(
                    text: "Projects Completed: $projectsCount",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.gray4B,
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: "Open hour: $openHour",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.gray4B,
                  ),
                  const Gap(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AppText(
                      text: bio,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.instance.textColor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    backgroundColor: _selectedTab == 0
                        ? AppColors.instance.primary
                        : AppColors.instance.transparent,
                    borderColor: _selectedTab == 0
                        ? AppColors.instance.primary
                        : AppColors.instance.gray4B.withValues(alpha: 0.3),
                    titleColor: _selectedTab == 0
                        ? AppColors.instance.containerBackground
                        : AppColors.instance.textColor,
                    title: "Services",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Gap(width: 8),
                Expanded(
                  child: AppButton(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    backgroundColor: _selectedTab == 1
                        ? AppColors.instance.primary
                        : AppColors.instance.transparent,
                    borderColor: _selectedTab == 1
                        ? AppColors.instance.primary
                        : AppColors.instance.gray4B.withValues(alpha: 0.3),
                    titleColor: _selectedTab == 1
                        ? AppColors.instance.containerBackground
                        : AppColors.instance.textColor,
                    title: "Old Projects",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Gap(width: 8),
                Expanded(
                  child: AppButton(
                    onTap: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                    backgroundColor: _selectedTab == 2
                        ? AppColors.instance.primary
                        : AppColors.instance.transparent,
                    borderColor: _selectedTab == 2
                        ? AppColors.instance.primary
                        : AppColors.instance.gray4B.withValues(alpha: 0.3),
                    titleColor: _selectedTab == 2
                        ? AppColors.instance.containerBackground
                        : AppColors.instance.textColor,
                    title: "Reviews",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const Gap(height: 20),

            // Tab Content Body
            if (_selectedTab == 0) _buildServicesTab(allServices),
            if (_selectedTab == 1) _buildOldProjectsTab(allProjects),
            if (_selectedTab == 2) _buildReviewsTab(allReviews),
            const Gap(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. Services Tab View
  Widget _buildServicesTab(List<ProfessionalServiceData> services) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: AppText(
            text: "No services listed yet",
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: services.map((item) {
          final imageUrl = (item.avatar != null && item.avatar!.isNotEmpty)
              ? item.avatar!
              : _defaultProjectImage;
          final priority = item.priorityLevel ?? "Regular";
          final price = item.price != null ? "Rates from €${item.price}/hr" : "";

          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12.0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.instance.containerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: AppColors.instance.gray200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const Gap(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: priority,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppText(
                      text: priority,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.instance.primary,
                    ),
                  ],
                ),
                const Gap(height: 4),
                if (price.isNotEmpty)
                  AppText(
                    text: price,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.instance.gray4B,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildOldProjectsTab(List<ProjectData> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: AppText(
            text: "No previous projects available",
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: projects.map((item) {
          final imageUrl =
              (item.images != null && item.images!.isNotEmpty)
                  ? item.images!.first
                  : _defaultProjectImage;
          final title = item.title ?? "Project";
          final type = item.recurrenceType ?? item.status ?? "Regular";

          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 12.0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.instance.containerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: AppColors.instance.gray200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const Gap(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppText(
                      text: type,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.instance.primary,
                    ),
                  ],
                ),
                const Gap(height: 6),
                GestureDetector(
                  onTap: () {
                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.customerViewDetails,
                      extra: item,
                    );
                  },
                  child: Row(
                    children: [
                      AppText(
                        text: "View details",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.instance.primary,
                      ),
                      const Gap(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.instance.primary),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Reviews Tab View
  Widget _buildReviewsTab(List<ReviewData> reviews) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: AppText(
            text: "No reviews yet",
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((item) {
        final avatar = (item.userAvatar != null && item.userAvatar!.isNotEmpty)
            ? item.userAvatar!
            : "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400";
        final reviewerName = item.userName ?? "Customer";
        final ratingValue = item.rating?.toDouble() ?? 0.0;
        final comment = (item.note != null && item.note!.isNotEmpty)
            ? item.note!
            : "No comment provided";
        final date = (item.createdAt != null && item.createdAt!.length >= 10)
            ? item.createdAt!.substring(0, 10)
            : "";

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.instance.containerBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(avatar),
                        backgroundColor: AppColors.instance.gray200,
                      ),
                      const Gap(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: reviewerName,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.textColor,
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < ratingValue.floor()
                                      ? Icons.star
                                      : (index < ratingValue
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  color: const Color(0xFFFFBE00),
                                  size: 14,
                                ),
                              ),
                              const Gap(width: 4),
                              AppText(
                                text: "$ratingValue",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.instance.textColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (date.isNotEmpty)
                    AppText(
                      text: date,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.instance.gray4B,
                    ),
                ],
              ),
              const Gap(height: 10),
              AppText(
                text: comment,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray4B,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          Row(
            children: [
              BackButtonWidget(onTap: () => AppRoutes.instance.pop()),
              const Gap(width: 16),
              AppText(
                text: "Artisan/Technician",
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.instance.textColor,
              ),
            ],
          ),
          const Gap(height: 20),
          Center(
            child: Column(
              children: [
                _shimmerBox(width: 84, height: 84, radius: 42),
                const Gap(height: 12),
                _shimmerBox(width: 160, height: 24),
                const Gap(height: 8),
                _shimmerBox(width: 120, height: 16),
                const Gap(height: 8),
                _shimmerBox(width: 140, height: 16),
                const Gap(height: 12),
                _shimmerBox(width: 240, height: 32),
              ],
            ),
          ),
          const Gap(height: 24),
          Row(
            children: [
              Expanded(child: _shimmerBox(width: double.infinity, height: 42, radius: 10)),
              const Gap(width: 8),
              Expanded(child: _shimmerBox(width: double.infinity, height: 42, radius: 10)),
              const Gap(width: 8),
              Expanded(child: _shimmerBox(width: double.infinity, height: 42, radius: 10)),
            ],
          ),
          const Gap(height: 24),
          _shimmerBox(width: double.infinity, height: 140, radius: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButtonWidget(onTap: () => AppRoutes.instance.pop()),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: AppColors.instance.red73),
                  const Gap(height: 12),
                  AppText(
                    text: message,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.instance.gray500,
                  ),
                ],
              ),
            ),
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
