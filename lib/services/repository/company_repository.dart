import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/company_service_category_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyRepository {
  CompanyRepository._privateConstructor();
  static final CompanyRepository _instance =
      CompanyRepository._privateConstructor();
  static CompanyRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches service category list from GET /company/service-category-list
  Future<CompanyServiceCategoryResponse?> getCompanyServiceCategoryList() async {
    try {
      final response = await _apiServices.getServices(
        _api.companyServiceCategoryList,
      );

      if (response != null) {
        return CompanyServiceCategoryResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('CompanyRepository.getCompanyServiceCategoryList', e);
    }
    return null;
  }

  /// Creates service category via POST /company/service-category using form-data
  Future<bool> createCompanyServiceCategory({
    required String categoryId,
    required String priorityLevel,
    required String price,
    String? avatarPath,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry("categoryId", categoryId));
      formData.fields.add(MapEntry("priorityLevel", priorityLevel));
      formData.fields.add(MapEntry("price", price));

      if (avatarPath != null &&
          avatarPath.isNotEmpty &&
          !avatarPath.startsWith('http') &&
          File(avatarPath).existsSync()) {
        final fileName = avatarPath.split('/').last.split('\\').last;
        final mimeType = lookupMimeType(avatarPath) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        final mediaType = MediaType(
          mimeSplit[0],
          mimeSplit.length > 1 ? mimeSplit[1] : 'jpeg',
        );

        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarPath,
              filename: fileName,
              contentType: mediaType,
            ),
          ),
        );
      }

      final response = await _apiServices.postServices(
        url: _api.companyServiceCategory,
        body: formData,
      );
      return response != null;
    } catch (e) {
      errorLog('CompanyRepository.createCompanyServiceCategory', e);
      return false;
    }
  }
}
