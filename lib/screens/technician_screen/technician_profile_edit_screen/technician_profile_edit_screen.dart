import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/technician_screen/technician_profile_edit_screen/provider/technician_profile_edit_provider.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/services/location/location_service.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/image_userPick/image_user_pick.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/map/leaflet_location_picker_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class TechnicianProfileEditScreen extends ConsumerStatefulWidget {
  const TechnicianProfileEditScreen({super.key});

  @override
  ConsumerState<TechnicianProfileEditScreen> createState() =>
      _TechnicianProfileEditScreenState();
}

class _TechnicianProfileEditScreenState
    extends ConsumerState<TechnicianProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _workingAddressController =
      TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  String? _selectedSchedule = "AVAILABLE_WEEKDAYS";
  String? _selectedAvatarPath;
  String _currentAvatarUrl = '';
  bool _isInitialized = false;
  bool _isLookingUpAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(technicianProfileProvider);
      if (profileState.profileDetails == null) {
        ref
            .read(technicianProfileProvider.notifier)
            .fetchProfileDetails(showLoading: false);
      } else {
        _populateProfileData(profileState.profileDetails);
        setState(() {});
      }
    });
  }

  void _populateProfileData(ProfessionalProfileDetailsModel? details) {
    final prof = details?.data?.professional;
    final user = prof?.user;

    if (user != null) {
      if (!_isInitialized || _nameController.text.isEmpty) {
        _nameController.text = user.name ?? '';
      }
      _currentAvatarUrl = user.avatar ?? '';
    }
    if (prof != null) {
      if (!_isInitialized || _vatController.text.isEmpty) {
        _vatController.text = prof.corporateVatNumber ?? '';
      }
      if (!_isInitialized) {
        final avail = (prof.availability ?? '').toUpperCase();
        if (avail.contains('FULL')) {
          _selectedSchedule = 'AVAILABLE_FULL_WEEK';
        } else if (avail.contains('WEEKEND')) {
          _selectedSchedule = 'AVAILABLE_WEEKENDS';
        } else if (avail.contains('WEEKDAY')) {
          _selectedSchedule = 'AVAILABLE_WEEKDAYS';
        } else if (prof.availability != null && prof.availability!.isNotEmpty) {
          _selectedSchedule = prof.availability;
        } else {
          _selectedSchedule = 'AVAILABLE_WEEKDAYS';
        }
      }
      if (!_isInitialized || _startTimeController.text.isEmpty) {
        _startTimeController.text =
            prof.workingTimeStart ??
            (prof.workingTime?.split('-').firstOrNull ?? '');
      }
      if (!_isInitialized || _endTimeController.text.isEmpty) {
        _endTimeController.text =
            prof.workingTimeEnd ??
            (prof.workingTime?.split('-').lastOrNull ?? '');
      }
      if (!_isInitialized || _workingAddressController.text.isEmpty) {
        _workingAddressController.text =
            prof.workingAddress ?? user?.address ?? '';
      }
      if (!_isInitialized || _latitudeController.text.isEmpty) {
        _latitudeController.text =
            prof.workingRadiusKmLatitude ?? (user?.latitude?.toString() ?? '');
      }
      if (!_isInitialized || _longitudeController.text.isEmpty) {
        _longitudeController.text =
            prof.workingRadiusKmLongitude ??
            (user?.longitude?.toString() ?? '');
      }
    }
    if (user != null || prof != null) {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vatController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _workingAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Widget _buildAvailabilityOption({
    required String label,
    required String value,
  }) {
    final bool isSelected = _selectedSchedule == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSchedule = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(width: 4,),
          Checkbox(
            value: isSelected,
            activeColor: AppColors.instance.primary,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.instance.primary
                  : AppColors.instance.textColor.withValues(alpha: 0.5),
            ),
            onChanged: (val) {
              if (val == true) {
                setState(() {
                  _selectedSchedule = value;
                });
              }
            },
          ),
          const Gap(width: 8),
          AppText(
            text: label,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.instance.textColor,
          ),
        ],
      ),
    );
  }

  Future<void> _lookupAddressFromCoordinates() async {
    final lat = double.tryParse(_latitudeController.text.trim());
    final lon = double.tryParse(_longitudeController.text.trim());

    if (lat == null || lon == null) {
      AppSnackBar.instance.error(
        "Please enter valid Latitude & Longitude numbers",
      );
      return;
    }

    setState(() {
      _isLookingUpAddress = true;
    });

    final address = await LocationService.instance.reverseGeocode(
      latitude: lat,
      longitude: lon,
    );

    if (mounted) {
      setState(() {
        _isLookingUpAddress = false;
        if (address != null && address.isNotEmpty) {
          _workingAddressController.text = address;
          AppSnackBar.instance.success("Address resolved: $address");
        } else {
          AppSnackBar.instance.error(
            "Could not find address for these coordinates",
          );
        }
      });
    }
  }

  Future<void> _openMapPicker() async {
    final initialLat =
        double.tryParse(_latitudeController.text.trim()) ?? 50.8503;
    final initialLng =
        double.tryParse(_longitudeController.text.trim()) ?? 4.3517;

    final result = await LeafletLocationPickerDialog.show(
      context,
      initialLatitude: initialLat,
      initialLongitude: initialLng,
      initialAddress: _workingAddressController.text.trim(),
    );

    if (result != null && mounted) {
      setState(() {
        _latitudeController.text = result.latitude.toString();
        _longitudeController.text = result.longitude.toString();
        _workingAddressController.text = result.address;
      });
      AppSnackBar.instance.success("Location selected from map!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(technicianProfileEditProvider);

    ref.listen<TechnicianProfileState>(technicianProfileProvider, (
      previous,
      next,
    ) {
      if (next.profileDetails != null) {
        _populateProfileData(next.profileDetails);
        if (mounted) {
          setState(() {});
        }
      }
    });

    final profileState = ref.watch(technicianProfileProvider);
    if (!_isInitialized && profileState.profileDetails != null) {
      _populateProfileData(profileState.profileDetails);
    }

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
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
                    const Gap(width: 12),
                    AppText(
                      text: "Personal details",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: AppColors.instance.bodyText,
                    ),
                  ],
                ),
                const Gap(height: 30),

                // Avatar Image Container with Camera Icon Picker
                Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: AppColors.instance.containerBackground,
                          child:
                              (_selectedAvatarPath != null &&
                                  _selectedAvatarPath!.isNotEmpty)
                              ? Image.file(
                                  File(_selectedAvatarPath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : AppImageCircular(
                                  height: 100,
                                  width: 100,
                                  url: _currentAvatarUrl.isNotEmpty
                                      ? _currentAvatarUrl
                                      : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768',
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: GestureDetector(
                            onTap: () {
                              appImageUserTake(
                                callBack: (path) {
                                  if (path.isNotEmpty) {
                                    setState(() {
                                      _selectedAvatarPath = path;
                                    });
                                  }
                                },
                              );
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.instance.black200,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(height: 20),

                // Full Name Input
                AppInputWidgetTwo(
                  controller: _nameController,
                  title: "Full Name",
                  hintText: "Enter full name",
                ),

                // Corporate Vat Input
                AppInputWidgetTwo(
                  controller: _vatController,
                  title: "Corporate Vat",
                  hintText: "Enter vat",
                  prefix: Icon(
                    Icons.badge_outlined,
                    color: AppColors.instance.textColor14,
                  ),
                ),
                const Gap(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Availability",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                      ),
                      const Gap(height: 8),
                      Transform.translate(
                        offset: const Offset(-4, 0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildAvailabilityOption(
                              label: "Available Weekdays",
                              value: "AVAILABLE_WEEKDAYS",
                            ),
                            _buildAvailabilityOption(
                              label: "Available Weekends",
                              value: "AVAILABLE_WEEKENDS",
                            ),
                            _buildAvailabilityOption(
                              label: "Available Full Week",
                              value: "AVAILABLE_FULL_WEEK",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(height: 8),

                AppInputWidgetTwo(
                  controller: _startTimeController,
                  title: "Start time",
                  hintText: "8.00",
                ),
                AppInputWidgetTwo(
                  controller: _endTimeController,
                  title: "End time",
                  hintText: "5.00",
                ),

                const Gap(height: 10),
                const Divider(height: 1, color: Color(0xFFEBE6E8)),
                const Gap(height: 14),

                // Working Location & Map Picker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.instance.primary,
                          size: 20,
                        ),
                        const Gap(width: 6),
                        AppText(
                          text: "Working Location & Map",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.instance.textColor,
                        ),
                      ],
                    ),
                    // Tap on Map Button
                    GestureDetector(
                      onTap: _openMapPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.instance.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.instance.primary.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.map_rounded,
                              color: AppColors.instance.primary,
                              size: 16,
                            ),
                            const Gap(width: 4),
                            AppText(
                              text: "Pick on Map",
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
                const Gap(height: 10),

                // Working Address Field
                AppInputWidgetTwo(
                  controller: _workingAddressController,
                  title: "Working Address",
                  hintText: "e.g. Avenue Louise 120, Brussels",
                  prefix: Icon(
                    Icons.home_work_outlined,
                    color: AppColors.instance.textColor14,
                  ),
                ),

                // Coordinates Row (Latitude & Longitude)
                // Row(
                //   children: [
                //     Expanded(
                //       child: AppInputWidgetTwo(
                //         controller: _latitudeController,
                //         title: "Latitude",
                //         hintText: "e.g. 50.8503",
                //         keyboardType: const TextInputType.numberWithOptions(
                //           decimal: true,
                //           signed: true,
                //         ),
                //       ),
                //     ),
                //     const Gap(width: 10),
                //     Expanded(
                //       child: AppInputWidgetTwo(
                //         controller: _longitudeController,
                //         title: "Longitude",
                //         hintText: "e.g. 4.3517",
                //         keyboardType: const TextInputType.numberWithOptions(
                //           decimal: true,
                //           signed: true,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

                // // Reverse Geocode Action Helper Button
                // const Gap(height: 6),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton.icon(
                //     onPressed: _isLookingUpAddress
                //         ? null
                //         : _lookupAddressFromCoordinates,
                //     icon: _isLookingUpAddress
                //         ? const SizedBox(
                //             width: 14,
                //             height: 14,
                //             child: CircularProgressIndicator(strokeWidth: 2),
                //           )
                //         : Icon(
                //             Icons.sync_rounded,
                //             size: 16,
                //             color: AppColors.instance.primary,
                //           ),
                //     label: AppText(
                //       text: "Get place name from Lat/Lng",
                //       fontSize: 12.5,
                //       fontWeight: FontWeight.w600,
                //       color: AppColors.instance.primary,
                //     ),
                //   ),
                // ),
                const Gap(height: 20),

                AppButton(
                  title: "Save Changes",
                  height: 48,
                  isLoading: editState.isLoading,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  onTap: () async {
                    final name = _nameController.text.trim();
                    final vat = _vatController.text.trim();
                    final availability =
                        _selectedSchedule ?? "AVAILABLE_WEEKDAYS";
                    final startTime = _startTimeController.text.trim();
                    final endTime = _endTimeController.text.trim();
                    final workingAddress = _workingAddressController.text
                        .trim();
                    final lat = _latitudeController.text.trim();
                    final lon = _longitudeController.text.trim();

                    final isSuccess = await ref
                        .read(technicianProfileEditProvider.notifier)
                        .updateAccount(
                          name: name,
                          availability: availability,
                          workingTimeStart: startTime,
                          workingTimeEnd: endTime,
                          corporateVatNumber: vat,
                          workingAddress: workingAddress,
                          workingRadiusKmLatitude: lat,
                          workingRadiusKmLongitude: lon,
                          avatarPath: _selectedAvatarPath,
                        );

                    if (isSuccess) {
                      AppSnackBar.instance.success(
                        "Profile updated successfully!",
                      );
                      if (_currentAvatarUrl.isNotEmpty) {
                        try {
                          await CachedNetworkImage.evictFromCache(
                            _currentAvatarUrl,
                          );
                          await CustomCacheManager.instance.removeFile(
                            _currentAvatarUrl,
                          );
                        } catch (_) {}
                      }
                      await ref
                          .read(technicianProfileProvider.notifier)
                          .fetchProfileDetails(showLoading: false);
                      if (mounted) {
                        AppRoutes.instance.pop();
                      }
                    }
                  },
                ),
                const Gap(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
