import 'dart:io';
import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class JobRepository {
  JobRepository._privateConstructor();
  static final JobRepository _instance = JobRepository._privateConstructor();
  static JobRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Creates a new job via POST /user/job using form-data.
  Future<dynamic> createJob({
    required String userId,
    required String categoryId,
    required String title,
    required String description,
    String? constructionYears,
    required String region,
    required String homeAsset,
    required String recurrenceType,
    required String wishRepairDate,
    required String budgetFee,
    required String address,
    String latitude = '',
    String longitude = '',
    List<String> imagePaths = const [],
    String? professionalId,
    String? urgency,
  }) async {
    try {
      final Map<String, dynamic> mapData = {
        'userId': userId,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'region': region,
        'home_asset': homeAsset,
        'recurrenceType': recurrenceType,
        'wishRepairDate': wishRepairDate,
        'budgetFee': budgetFee,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

      if (urgency != null && urgency.isNotEmpty) {
        mapData['urgency'] = urgency;
      }

      if (constructionYears != null && constructionYears.isNotEmpty) {
        mapData['construction_years'] = constructionYears;
      }

      if (professionalId != null && professionalId.isNotEmpty) {
        mapData['professionalId'] = professionalId;
      }

      final List<MultipartFile> multipartImages = [];
      for (String path in imagePaths) {
        if (!path.startsWith('http') && File(path).existsSync()) {
          final fileName = path.split('/').last.split('\\').last;
          multipartImages.add(
            await MultipartFile.fromFile(path, filename: fileName),
          );
        }
      }

      if (multipartImages.isNotEmpty) {
        mapData['images'] = multipartImages;
      }

      final formData = FormData.fromMap(mapData);

      final response = await _apiServices.postServices(
        url: _api.createJob,
        body: formData,
      );

      return response;
    } catch (e) {
      errorLog('JobRepository.createJob', e);
      AppSnackBar.instance.error('Failed to create job. Please try again.');
      return null;
    }
  }
}
