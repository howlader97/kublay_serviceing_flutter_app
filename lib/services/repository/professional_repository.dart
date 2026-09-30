import 'dart:io';
import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class ProfessionalRepository {
  ProfessionalRepository._privateConstructor();
  static final ProfessionalRepository _instance =
      ProfessionalRepository._privateConstructor();
  static ProfessionalRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;
  final StorageServices _storageServices = StorageServices.instance;

  /// Fetches details profile for the logged in professional user
  Future<ProfessionalProfileDetailsModel?> getProfessionalProfileDetails({
    String? customProfessionalId,
  }) async {
    try {
      final professionalId =
          customProfessionalId ?? await _storageServices.getProfessionalId();

      if (professionalId.isEmpty) {
        errorLog('ProfessionalRepository', 'Professional ID is empty');
        return null;
      }

      final response = await _apiServices.getServices(
        _api.professionalDetailsProfile(professionalId),
      );

      if (response != null && response is Map<String, dynamic>) {
        return ProfessionalProfileDetailsModel.fromJson(response);
      }
    } catch (e) {
      errorLog('ProfessionalRepository.getProfessionalProfileDetails', e);
    }
    return null;
  }

  /// Fetches all professional jobs via GET /user/all-jobs-professional
  Future<TechnicianJobResponse?> getAllJobsProfessional({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiServices.getServices(
        _api.allJobsProfessional,
        queryParameters: {
          "page": page,
          "limit": limit,
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        return TechnicianJobResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('ProfessionalRepository.getAllJobsProfessional', e);
    }
    return null;
  }

  /// Fetches technician work list by date via GET /professional/{professionalId}/work-list-by-date
  Future<TechnicianJobResponse?> getWorkListByDate({
    String? customProfessionalId,
    required String dateIso,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final professionalId =
          customProfessionalId ?? await _storageServices.getProfessionalId();

      if (professionalId.isEmpty) {
        errorLog('ProfessionalRepository.getWorkListByDate', 'Professional ID is empty');
        return null;
      }

      final response = await _apiServices.getServices(
        _api.professionalWorkListByDate(professionalId),
        body: {
          "date": dateIso,
        },
        queryParameters: {
          "page": page,
          "limit": limit,
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        return TechnicianJobResponse.fromJson(response);
      }
    } catch (e) {
      errorLog('ProfessionalRepository.getWorkListByDate', e);
    }
    return null;
  }

  /// Posts task evidence via POST /professional/task-evidence
  Future<bool> postTaskEvidence({
    required String jobId,
    required String summary,
    required String note,
    required List<File> imageFiles,
  }) async {
    try {
      final mapData = <String, dynamic>{
        'jobId': jobId,
        'summary': summary,
        'note': note,
      };

      if (imageFiles.isNotEmpty) {
        final List<MultipartFile> multipartImages = [];
        for (File file in imageFiles) {
          if (file.existsSync()) {
            final fileName = file.path.split('/').last.split('\\').last;
            multipartImages.add(
              await MultipartFile.fromFile(file.path, filename: fileName),
            );
          }
        }
        if (multipartImages.isNotEmpty) {
          mapData['images'] = multipartImages;
        }
      }

      final formData = FormData.fromMap(mapData);

      final response = await _apiServices.postServices(
        url: _api.postTaskEvidence,
        body: formData,
      );

      if (response != null) {
        final msg = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : "Task evidence submitted successfully!";
        AppSnackBar.instance.success(msg);
        return true;
      }
    } catch (e) {
      errorLog('ProfessionalRepository.postTaskEvidence', e);
    }
    return false;
  }

  /// Submits appeal/report for a review via POST /common/report
  Future<bool> submitReport({
    required String jobId,
    required String reviewId,
    required String reporterId,
    required String reportedId,
    required String reason,
    required String comment,
  }) async {
    try {
      final bodyData = {
        "jobId": jobId,
        "reviewId": reviewId,
        "reporterId": reporterId,
        "reportedId": reportedId,
        "reason": reason,
        "comment": comment,
      };

      final response = await _apiServices.postServices(
        url: _api.commonReport,
        body: bodyData,
      );

      if (response != null) {
        final msg = (response is Map && response['message'] != null)
            ? response['message'].toString()
            : "Appeal submitted successfully!";
        AppSnackBar.instance.success(msg);
        return true;
      }
    } catch (e) {
      errorLog('ProfessionalRepository.submitReport', e);
    }
    return false;
  }
}
