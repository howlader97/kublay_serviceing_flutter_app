import 'package:dio/dio.dart';
import 'package:belwork/utils/app_log.dart';

class LocationSearchResult {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? city;
  final String? country;

  LocationSearchResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.city,
    this.country,
  });
}

class LocationService {
  LocationService._privateConstructor();
  static final LocationService _instance =
      LocationService._privateConstructor();
  static LocationService get instance => _instance;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent':
            'BelworkApp/1.0 (https://topackubilaybackend.maktechapp.cloud)',
        'Accept': 'application/json',
      },
    ),
  );

  static const String _locationIqApiKey = "pk.76612b7a94fc7b2a652a2ffcb3258c70";

  /// Reverse geocode: Takes latitude & longitude and returns human-readable place name / address
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    // 1. Try LocationIQ
    try {
      if (_locationIqApiKey.isNotEmpty) {
        final url =
            "https://us1.locationiq.com/v1/reverse?key=$_locationIqApiKey&lat=$latitude&lon=$longitude&format=json";
        final response = await _dio.get(url);
        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map;
          final displayName = data["display_name"]?.toString();
          if (displayName != null && displayName.isNotEmpty) {
            return _formatCleanAddress(displayName, data["address"]);
          }
        }
      }
    } catch (e) {
      errorLog('LocationService.locationIqReverseGeocode', e);
    }

    // 2. Fallback to OpenStreetMap Nominatim
    try {
      final url =
          "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final displayName = data["display_name"]?.toString();
        if (displayName != null && displayName.isNotEmpty) {
          return _formatCleanAddress(displayName, data["address"]);
        }
      }
    } catch (e) {
      errorLog('LocationService.nominatimReverseGeocode', e);
    }

    return null;
  }

  /// Forward geocode: Searches places matching query text and returns lat/long coordinates
  Future<List<LocationSearchResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) return [];

    // 1. Try LocationIQ Search
    try {
      if (_locationIqApiKey.isNotEmpty) {
        final url =
            "https://us1.locationiq.com/v1/search?key=$_locationIqApiKey&q=${Uri.encodeComponent(query.trim())}&format=json&limit=5";
        final response = await _dio.get(url);
        if (response.statusCode == 200 && response.data is List) {
          final list = <LocationSearchResult>[];
          for (final item in response.data) {
            if (item is Map) {
              final lat = double.tryParse(item["lat"]?.toString() ?? "");
              final lon = double.tryParse(item["lon"]?.toString() ?? "");
              final name = item["display_name"]?.toString() ?? "";
              if (lat != null && lon != null && name.isNotEmpty) {
                list.add(
                  LocationSearchResult(
                    latitude: lat,
                    longitude: lon,
                    displayName: name,
                  ),
                );
              }
            }
          }
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      errorLog('LocationService.locationIqSearch', e);
    }

    // 2. Fallback to OpenStreetMap Nominatim Search
    try {
      final url =
          "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query.trim())}&format=json&limit=5";
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        final list = <LocationSearchResult>[];
        for (final item in response.data) {
          if (item is Map) {
            final lat = double.tryParse(item["lat"]?.toString() ?? "");
            final lon = double.tryParse(item["lon"]?.toString() ?? "");
            final name = item["display_name"]?.toString() ?? "";
            if (lat != null && lon != null && name.isNotEmpty) {
              list.add(
                LocationSearchResult(
                  latitude: lat,
                  longitude: lon,
                  displayName: name,
                ),
              );
            }
          }
        }
        return list;
      }
    } catch (e) {
      errorLog('LocationService.nominatimSearch', e);
    }

    return [];
  }

  String _formatCleanAddress(String fullAddress, dynamic addressMap) {
    if (addressMap is Map) {
      final road =
          addressMap["road"] ??
          addressMap["pedestrian"] ??
          addressMap["street"];
      final neighbourhood = addressMap["neighbourhood"] ?? addressMap["suburb"];
      final city =
          addressMap["city"] ??
          addressMap["town"] ??
          addressMap["municipality"] ??
          addressMap["village"];
      final state = addressMap["state"] ?? addressMap["province"];
      final country = addressMap["country"];

      final parts = <String>[];
      if (road != null && road.toString().isNotEmpty) {
        parts.add(road.toString());
      }
      if (neighbourhood != null &&
          neighbourhood.toString().isNotEmpty &&
          neighbourhood != road) {
        parts.add(neighbourhood.toString());
      }
      if (city != null && city.toString().isNotEmpty && city != neighbourhood) {
        parts.add(city.toString());
      }
      if (state != null && state.toString().isNotEmpty && state != city) {
        parts.add(state.toString());
      }
      if (country != null && country.toString().isNotEmpty) {
        parts.add(country.toString());
      }

      if (parts.isNotEmpty) {
        return parts.join(", ");
      }
    }
    return fullAddress;
  }
}
