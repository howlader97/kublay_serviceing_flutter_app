import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/all_professional_response.dart';
import 'package:belwork/models/professional_by_category_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class CustomerHomeRepository {
  ////////////// Constructors
  CustomerHomeRepository._privateConstructor();
  static final CustomerHomeRepository _instance =
      CustomerHomeRepository._privateConstructor();
  static CustomerHomeRepository get instance => _instance;

  ////////////// Objects
  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  ////////////// Functions

  /// Fetches a paginated list of all professionals.
  /// [page] - current page number (1-indexed)
  /// [limit] - number of items per page
  Future<AllProfessionalResponse?> getAllProfessionals({
    required int page,
    int limit = 10,
  }) async {
    try {
      final response = await _apiServices.getServices(
        _api.allProfessionalsList,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response != null) {
        return AllProfessionalResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('CustomerHomeRepository.getAllProfessionals', e);
    }
    return null;
  }

  /// Fetches professionals filtered by category ID.
  Future<ProfessionalByCategoryResponse?> getProfessionalsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiServices.postServices(
        url: _api.professionalListByCategories,
        body: {"category": categoryId},
        query: {'page': page, 'limit': limit},
      );
      if (response != null && response is Map<String, dynamic>) {
        return ProfessionalByCategoryResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('CustomerHomeRepository.getProfessionalsByCategory', e);
    }
    return null;
  }

  /// Fetches nearest professionals by category, latitude, longitude, and radius (km).
  Future<List<ProfessionalByCategoryItem>> getNearestProfessionalsByCategory({
    required String lat,
    required String lng,
    required String radiusKm,
    required String category,
  }) async {
    try {
      final requestData = {
        "lat": lat,
        "lng": lng,
        "radiusKm": radiusKm,
        "category": category,
      };
      final response = await _apiServices.getServices(
        _api.nearestProfessionalsByCategory,
        body: requestData,
        queryParameters: requestData,
      );
      if (response != null) {
        if (response is List) {
          return response
              .map(
                (e) => ProfessionalByCategoryItem.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
        } else if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is List) {
            return data
                .map(
                  (e) => ProfessionalByCategoryItem.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else if (data is Map<String, dynamic>) {
            final allProf = data['allProfessional'];
            if (allProf is List) {
              return allProf
                  .map(
                    (e) => ProfessionalByCategoryItem.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList();
            }
          }
        }
      }
    } catch (e) {
      errorLog('CustomerHomeRepository.getNearestProfessionalsByCategory', e);
    }
    return [];
  }
}
