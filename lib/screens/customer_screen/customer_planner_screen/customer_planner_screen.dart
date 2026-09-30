import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/yearly_inspection_response.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/provider/yearly_inspection_provider.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/widgets/asset_image_slider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerPlannerScreen extends ConsumerStatefulWidget {
  const CustomerPlannerScreen({super.key});

  @override
  ConsumerState<CustomerPlannerScreen> createState() =>
      _CustomerPlannerScreenState();
}

class _CustomerPlannerScreenState
    extends ConsumerState<CustomerPlannerScreen> {
  int _selectedTabIndex = 0;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatInspectMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return _monthNames[parsed.month - 1];
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context),
              const Gap(height: 16),
              _buildTabToggle(context),
              const Gap(height: 20),
              AppText(
                text: _selectedTabIndex == 0
                    ? 'Registered assets'
                    : 'Regular assets',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.instance.textColor,
              ),
              const Gap(height: 14),
              _selectedTabIndex == 0
                  ? _buildRegisteredAssetsList()
                  : _buildRegularAssetsList(),
              const Gap(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
                text: 'Annual inspection',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.instance.textColor),
            const SizedBox(height: 2),
            AppText(
                text: 'Asset maintenance scheduler',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray500),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await AppRoutes.instance
                .pushNamed(AppRoutesKey.instance.customerPlannerAddScreen);
            ref
                .read(yearlyInspectionProvider.notifier)
                .fetchYearlyInspections();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.instance.primary,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildTabToggle(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = 0;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedTabIndex == 0
                  ? AppColors.instance.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _selectedTabIndex == 0
                      ? AppColors.instance.primary
                      : AppColors.instance.gray200
                          .withValues(alpha: 0.5)),
            ),
            child: AppText(
              text: 'Registered equipment',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _selectedTabIndex == 0
                  ? Colors.white
                  : AppColors.instance.gray500,
            ),
          ),
        ),
        const Gap(width: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = 1;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedTabIndex == 1
                  ? AppColors.instance.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _selectedTabIndex == 1
                      ? AppColors.instance.primary
                      : AppColors.instance.gray200
                          .withValues(alpha: 0.5)),
            ),
            child: AppText(
              text: 'Regular',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _selectedTabIndex == 1
                  ? Colors.white
                  : AppColors.instance.gray500,
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 0: Registered Assets (Annual recur)
  Widget _buildRegisteredAssetsList() {
    final yearlyAsync = ref.watch(yearlyInspectionProvider);

    return yearlyAsync.when(
      data: (items) {
        final annualItems = items
            .where((item) =>
                item.recurrenceType == 'ANNUAL_INSPECTION' ||
                item.recurrenceType == null ||
                (item.recurrenceType != 'REGULAR' &&
                    item.recurrenceType != 'EMERGENCY'))
            .toList();

        if (annualItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: 'No registered assets found',
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: annualItems.length,
          itemBuilder: (context, index) {
            final item = annualItems[index];
            return _buildAssetCard(context, item);
          },
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: AppText(
            text: 'Failed to load registered assets',
            fontSize: 14,
            color: AppColors.instance.red73,
          ),
        ),
      ),
    );
  }

  /// Tab 1: Regular & Emergency Assets
  Widget _buildRegularAssetsList() {
    final yearlyAsync = ref.watch(yearlyInspectionProvider);

    return yearlyAsync.when(
      data: (items) {
        final regularItems = items
            .where((item) =>
                item.recurrenceType == 'REGULAR' ||
                item.recurrenceType == 'EMERGENCY')
            .toList();

        if (regularItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: 'No regular or emergency assets found',
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: regularItems.length,
          itemBuilder: (context, index) {
            final item = regularItems[index];
            return _buildAssetCard(context, item);
          },
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: AppText(
            text: 'Failed to load regular assets',
            fontSize: 14,
            color: AppColors.instance.red73,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, YearlyInspectionItem item) {
    final hasImages = item.images != null && item.images!.isNotEmpty;
    const double notchWidth = 103;
    const double notchHeight = 44;

    final titleText = (item.title != null && item.title!.isNotEmpty)
        ? item.title!
        : (item.homeAsset ?? 'Asset name');
    final inspectMonth = _formatInspectMonth(item.wishRepairDate);

    // Recurrence badge determination
    final String badgeText;
    if (item.recurrenceType == 'EMERGENCY') {
      badgeText = 'EMERGENCY';
    } else if (item.recurrenceType == 'REGULAR') {
      badgeText = 'Regular';
    } else if (item.recurrenceType == 'ANNUAL_INSPECTION') {
      badgeText = 'Annual recur';
    } else {
      badgeText = item.recurrenceType ?? 'Annual recur';
    }

    final Color badgeColor = badgeText.toUpperCase().contains('EMERGENCY')
        ? const Color(0xFFFF4D4F)
        : const Color(0xFFF07D1E);

    final Color badgeTextColor = badgeText.toUpperCase().contains('EMERGENCY')
        ? Colors.white
        : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Stack(
        children: [
          ClipPath(
            clipper: const AssetCardNotchClipper(
                notchWidth: notchWidth, notchHeight: notchHeight, radius: 8),
            child: Container(
              width: double.infinity,
              color: AppColors.instance.containerBackground,
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((item.urgency != null && item.urgency!.isNotEmpty) ||
                      (item.region != null && item.region!.isNotEmpty)) ...[
                    _buildUrgencyBadge((item.urgency != null && item.urgency!.isNotEmpty)
                        ? item.urgency!
                        : item.region!),
                    const Gap(height: 12)
                  ],
                  if (hasImages) ...[
                    const Gap(height: 12),
                    SizedBox(
                        width: 260,
                        child: AssetImageSlider(images: item.images!)),
                    const Gap(height: 10)
                  ],
                  AppText(
                      text: titleText,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.textColor),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText(
                          text: 'Target recurrent inspect: ',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.instance.textColor),
                      AppText(
                          text: inspectMonth,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.instance.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: 'Description: ${item.description ?? ''}',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.instance.gray500,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 94,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  text: badgeText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: badgeTextColor,
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: 0,
          //   right: 0,
          //   child: Container(
          //     width: 94,
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          //     decoration: BoxDecoration(
          //         color: badgeColor,
          //         borderRadius: BorderRadius.circular(4)),
          //     child: Center(
          //       child: AppText(
          //           text: badgeText,
          //           fontSize: 13,
          //           fontWeight: FontWeight.w600,
          //           color: badgeTextColor),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    if (urgency.isEmpty) return const SizedBox.shrink();
    Color badgeColor;
    if (urgency.toUpperCase().contains('HIGH')) {
      badgeColor = const Color(0xFFFF5252);
    } else if (urgency.toUpperCase().contains('MEDIUM')) {
      badgeColor = const Color(0xFFFF9800);
    } else {
      badgeColor = AppColors.instance.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1.2),
      ),
      child: AppText(
          text: urgency,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor),
    );
  }
}

class AssetCardNotchClipper extends CustomClipper<Path> {
  final double notchWidth;
  final double notchHeight;
  final double radius;

  const AssetCardNotchClipper(
      {this.notchWidth = 125, this.notchHeight = 38, this.radius = 16});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    path.moveTo(r, 0);

    path.lineTo(w - notchWidth - r, 0);

    path.quadraticBezierTo(w - notchWidth, 0, w - notchWidth, r);

    path.lineTo(w - notchWidth, notchHeight - r);

    path.quadraticBezierTo(
        w - notchWidth, notchHeight, w - notchWidth + r, notchHeight);

    path.lineTo(w - r, notchHeight);

    path.quadraticBezierTo(w, notchHeight, w, notchHeight + r);

    path.lineTo(w, h - r);

    path.quadraticBezierTo(w, h, w - r, h);

    path.lineTo(r, h);

    path.quadraticBezierTo(0, h, 0, h - r);

    path.lineTo(0, r);

    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
