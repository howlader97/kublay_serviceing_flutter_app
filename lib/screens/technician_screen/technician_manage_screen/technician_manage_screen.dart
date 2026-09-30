import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/profile_card_widgets.dart';
import 'package:belwork/screens/technician_screen/technician_manage_screen/provider/technician_manage_provider.dart';
import 'package:belwork/screens/technician_screen/technician_manage_screen/widgets/category_card.dart';
import 'package:belwork/screens/technician_screen/technician_manage_screen/widgets/catelog_buttton.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class TechnicianManageScreen extends ConsumerStatefulWidget {
  const TechnicianManageScreen({super.key});

  @override
  ConsumerState<TechnicianManageScreen> createState() =>
      _TechnicianManageScreenState();
}

class _TechnicianManageScreenState
    extends ConsumerState<TechnicianManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(technicianManageProvider.notifier).fetchServiceCategories();
      ref.read(technicianProfileProvider.notifier).fetchProfileDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final manageState = ref.watch(technicianManageProvider);
    final categories = manageState.categories;

    final profileState = ref.watch(technicianProfileProvider);
    final profData = profileState.profileDetails?.data?.professional;
    final userData = profData?.user;

    final openHour =
        (profData?.workingTimeStart != null &&
            profData!.workingTimeStart!.isNotEmpty)
        ? profData.workingTimeStart!
        : (profData?.workingTime?.split('-').firstOrNull ?? "8.00");

    final closeHour =
        (profData?.workingTimeEnd != null &&
            profData!.workingTimeEnd!.isNotEmpty)
        ? profData.workingTimeEnd!
        : (profData?.workingTime?.split('-').lastOrNull ?? "18.00");

    final workingAddress =
        profData?.workingAddress ??
        (userData?.address != null && userData!.address!.isNotEmpty
            ? userData.address!
            : "No working address configured");

    final latStr =
        profData?.workingRadiusKmLatitude ??
        userData?.latitude?.toString() ??
        "";
    final lonStr =
        profData?.workingRadiusKmLongitude ??
        userData?.longitude?.toString() ??
        "";
    final double? latitude = double.tryParse(latStr);
    final double? longitude = double.tryParse(lonStr);
    final hasValidCoordinates = latitude != null && longitude != null;

    const defaultImage =
        "https://images.unsplash.com/photo-1542013936693-884638332954?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const Gap(height: 8),
                ProfileCardWidget(
                  image:
                      (userData?.avatar != null && userData!.avatar!.isNotEmpty)
                      ? userData.avatar!
                      : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768',
                  title: userData?.name ?? 'Ronald Richards',
                  subTitle: profData?.corporateVatNumber ?? 'BE 0876.543.210',
                ),
                const Gap(height: 8),

                // Operational Controls Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.instance.containerBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            text: "Operational controls",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.instance.textColor,
                          ),
                          GestureDetector(
                            onTap: () {
                              AppRoutes.instance.pushNamed(
                                AppRoutesKey
                                    .instance
                                    .technicianProfileEditScreen,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.instance.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: AppColors.instance.primary,
                                  ),
                                  const Gap(width: 4),
                                  AppText(
                                    text: "Edit",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.instance.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(height: 12),

                      // Hours Row
                      Row(
                        children: [
                          Expanded(
                            child: AppInputWidgetTwo(
                              hintText: openHour,
                              title: "Open hour",
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const Gap(width: 10),
                          Expanded(
                            child: AppInputWidgetTwo(
                              hintText: closeHour,
                              title: "Close hour",
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(height: 6),

                      const AppInputWidgetTwo(
                        hintText: "10",
                        title: "Dispatch zone (KM)",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      const Gap(height: 14),

                      // Working Location & Leaflet Map Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD6CED1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.instance.primary,
                                  size: 20,
                                ),
                                const Gap(width: 6),
                                Expanded(
                                  child: AppText(
                                    text: "Working Location & Base",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.instance.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(height: 6),

                            // Address string
                            AppText(
                              text: workingAddress,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.instance.textColor,
                              maxLines: 2,
                            ),
                            const Gap(height: 4),

                            // Lat & Long details
                            AppText(
                              text: hasValidCoordinates
                                  ? "Lat: ${latitude.toStringAsFixed(4)}  •  Lng: ${longitude.toStringAsFixed(4)}"
                                  : "Coordinates: Not set yet",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.instance.gray4B,
                            ),
                            const Gap(height: 10),

                            // Mini Leaflet Map Preview
                            if (hasValidCoordinates)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  height: 130,
                                  width: double.infinity,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        latitude,
                                        longitude,
                                      ),
                                      initialZoom: 13,
                                      interactionOptions:
                                          const InteractionOptions(
                                            flags: InteractiveFlag
                                                .none, // Static preview
                                          ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.topackubilayapp.belworkapp',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(latitude, longitude),
                                            width: 36,
                                            height: 36,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.instance.primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.build_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  AppRoutes.instance.pushNamed(
                                    AppRoutesKey
                                        .instance
                                        .technicianProfileEditScreen,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.instance.primary
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.instance.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        size: 16,
                                        color: AppColors.instance.primary,
                                      ),
                                      const Gap(width: 6),
                                      AppText(
                                        text:
                                            "Tap to configure location on Map",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.instance.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(height: 8),
                const CatelogButton(),
                const Gap(height: 8),
                if (manageState.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.instance.primary,
                      ),
                    ),
                  )
                else if (categories.isNotEmpty)
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 220
                        ),
                    shrinkWrap: true,
                    itemCount: categories.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final categoryInfo = item.category;

                      String cardImage = defaultImage;
                      if (item.avatar != null && item.avatar!.isNotEmpty) {
                        cardImage = item.avatar!;
                      } else if (categoryInfo?.avatar != null &&
                          categoryInfo!.avatar!.isNotEmpty) {
                        cardImage = categoryInfo.avatar!;
                      }

                      return CategoryCard(
                        image: cardImage,
                        title: categoryInfo?.name ?? 'Category',
                        service: categoryInfo?.type ?? 'Regular',
                        priceText: 'Rates from €${item.price ?? '0'}/hr',
                      );
                    },
                  )
                else Align(
                  child: Padding(padding: EdgeInsetsGeometry.all(20), child: AppText(text: "No Catelog Found"),),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
