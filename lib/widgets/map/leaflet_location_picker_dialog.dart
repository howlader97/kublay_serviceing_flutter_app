import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/services/location/location_service.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/utils/languages/app_translator.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapLocationResult {
  final double latitude;
  final double longitude;
  final String address;

  MapLocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LeafletLocationPickerDialog extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String initialAddress;

  const LeafletLocationPickerDialog({
    super.key,
    this.initialLatitude = 50.8503, // Default center (Brussels/Europe or custom)
    this.initialLongitude = 4.3517,
    this.initialAddress = '',
  });

  static Future<MapLocationResult?> show(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
    String? initialAddress,
  }) {
    return showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeafletLocationPickerDialog(
        initialLatitude: initialLatitude ?? 50.8503,
        initialLongitude: initialLongitude ?? 4.3517,
        initialAddress: initialAddress ?? '',
      ),
    );
  }

  @override
  State<LeafletLocationPickerDialog> createState() =>
      _LeafletLocationPickerDialogState();
}

class _LeafletLocationPickerDialogState
    extends State<LeafletLocationPickerDialog> {
  late final MapController _mapController;
  late LatLng _selectedPoint;
  String _currentAddress = "";
  bool _isGeocoding = false;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  List<LocationSearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPoint = LatLng(widget.initialLatitude, widget.initialLongitude);
    _currentAddress = widget.initialAddress;

    if (_currentAddress.isEmpty) {
      _reverseGeocodePoint(_selectedPoint);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocodePoint(LatLng point) async {
    setState(() {
      _isGeocoding = true;
    });

    final address = await LocationService.instance.reverseGeocode(
      latitude: point.latitude,
      longitude: point.longitude,
    );

    if (mounted) {
      setState(() {
        _isGeocoding = false;
        if (address != null && address.isNotEmpty) {
          _currentAddress = address;
        } else {
          _currentAddress =
              "Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})";
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await LocationService.instance.searchAddress(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _onLocationSelected(LatLng point, {String? placeName}) {
    setState(() {
      _selectedPoint = point;
      _searchResults = [];
      _searchController.clear();
    });
    _mapController.move(point, 15);

    if (placeName != null && placeName.isNotEmpty) {
      setState(() {
        _currentAddress = placeName;
      });
    } else {
      _reverseGeocodePoint(point);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            // Top Drag Handle & Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBE6E8), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.map_rounded,
                            color: AppColors.instance.primary,
                            size: 22,
                          ),
                          const Gap(width: 8),
                          AppText(
                            text: "Select Working Location",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.instance.textColor,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.instance.containerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final language = ref.watch(languageProvider);
                    final hint = AppTranslator.localTrans(
                          "Search city, street or area",
                          language,
                        ) ??
                        "Search city, street or area";

                    return TextField(
                      controller: _searchController,
                      onChanged: (val) => _performSearch(val),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: hint,
                    hintStyle: TextStyle(
                      color: AppColors.instance.black,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.instance.primary,
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              )
                            : null),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    ),
                  );
                },
              ),
            ),
          ),

            // Search Suggestions Dropdown (if searching)
            if (_searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFEBE6E8)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF0ECEE)),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.instance.primary,
                        size: 20,
                      ),
                      title: AppText(
                        text: item.displayName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        maxLines: 2,
                      ),
                      onTap: () {
                        _onLocationSelected(
                          LatLng(item.latitude, item.longitude),
                          placeName: item.displayName,
                        );
                      },
                    );
                  },
                ),
              ),

            // Leaflet Map Area
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 14,
                      minZoom: 3,
                      maxZoom: 19,
                      onTap: (tapPosition, point) {
                        _onLocationSelected(point);
                      },
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
                            point: _selectedPoint,
                            width: 50,
                            height: 50,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.instance.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.build_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xffAA1C41),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Floating Map Controls (Zoom In/Out, Center)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Column(
                      children: [
                        _buildMapActionButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            final zoom = _mapController.camera.zoom + 1;
                            _mapController.move(_selectedPoint, zoom);
                          },
                        ),
                        const Gap(height: 8),
                        _buildMapActionButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            final zoom = _mapController.camera.zoom - 1;
                            _mapController.move(_selectedPoint, zoom);
                          },
                        ),
                        const Gap(height: 8),
                        _buildMapActionButton(
                          icon: Icons.my_location_rounded,
                          color: AppColors.instance.primary,
                          onTap: () {
                            _mapController.move(_selectedPoint, 15);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tap instruction banner
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.touch_app_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          const Gap(width: 4),
                          AppText(
                            text: "Tap anywhere on map to move pin",
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Selected Address Details Card & Confirm Button
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.instance.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.instance.primary,
                            size: 24,
                          ),
                        ),
                        const Gap(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    text: "Working Address",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.instance.gray4B,
                                  ),
                                  if (_isGeocoding) ...[
                                    const Gap(width: 8),
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const Gap(height: 2),
                              AppText(
                                text: _currentAddress.isNotEmpty
                                    ? _currentAddress
                                    : "Fetching location name...",
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.instance.textColor,
                                maxLines: 2,
                              ),
                              const Gap(height: 4),
                              AppText(
                                text:
                                    "Lat: ${_selectedPoint.latitude.toStringAsFixed(6)}  •  Lng: ${_selectedPoint.longitude.toStringAsFixed(6)}",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.instance.gray50,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(height: 14),
                    AppButton(
                      title: "Confirm Location",
                      backgroundColor: AppColors.instance.primary,
                      titleColor: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      borderRadius: BorderRadius.circular(12),
                      height: 48,
                      onTap: () {
                        Navigator.of(context).pop(
                          MapLocationResult(
                            latitude: _selectedPoint.latitude,
                            longitude: _selectedPoint.longitude,
                            address: _currentAddress,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black87, size: 20),
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      ),
    );
  }
}
