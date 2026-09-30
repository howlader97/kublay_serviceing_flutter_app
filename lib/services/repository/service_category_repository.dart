import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class ServiceCategoryRepository {
  ////////////// Constructors
  ServiceCategoryRepository._privateConstructor();
  static final ServiceCategoryRepository _instance =
      ServiceCategoryRepository._privateConstructor();
  static ServiceCategoryRepository get instance => _instance;

  ////////////// Objects
  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  ////////////// Functions

  /// Fetches all service categories from API.
  Future<ServiceCategoryResponse?> getAllServiceCategories() async {
    try {
      final response = await _apiServices.getServices(
        _api.allServiceCategoryList,
      );
      if (response != null) {
        return ServiceCategoryResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('ServiceCategoryRepository.getAllServiceCategories', e);
    }
    return null;
  }
}
