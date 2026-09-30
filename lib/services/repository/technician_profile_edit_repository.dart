import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianProfileEditRepository {
  TechnicianProfileEditRepository._privateConstructor();
  static final TechnicianProfileEditRepository _instance =
      TechnicianProfileEditRepository._privateConstructor();
  static TechnicianProfileEditRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;
  final StorageServices _storageServices = StorageServices.instance;

  /// Updates technician account details via PATCH /professional/update-account/{professionalId}
  Future<dynamic> updateAccount({
    String? name,
    String? availability,
    String? workingTimeStart,
    String? workingTimeEnd,
    String? corporateVatNumber,
    String? workingRadiusKmLatitude,
    String? workingRadiusKmLongitude,
    String? workingAddress,
    String? avatarPath,
    String? customProfessionalId,
  }) async {
    try {
      final professionalId =
          customProfessionalId ?? await _storageServices.getProfessionalId();

      if (professionalId.isEmpty) {
        errorLog('TechnicianProfileEditRepository', 'Professional ID is empty');
        return null;
      }

      final url = _api.updateProfessionalAccount(professionalId);

      Map<String, dynamic> bodyMap = {};
      if (name != null && name.trim().isNotEmpty) {
        bodyMap["name"] = name.trim();
      }
      if (availability != null && availability.trim().isNotEmpty) {
        bodyMap["availability"] = availability.trim();
      }
      if (workingTimeStart != null && workingTimeStart.trim().isNotEmpty) {
        bodyMap["working_time_start"] = workingTimeStart.trim();
      }
      if (workingTimeEnd != null && workingTimeEnd.trim().isNotEmpty) {
        bodyMap["working_time_end"] = workingTimeEnd.trim();
      }
      if (corporateVatNumber != null && corporateVatNumber.trim().isNotEmpty) {
        bodyMap["corporateVatNumber"] = corporateVatNumber.trim();
      }
      if (workingRadiusKmLatitude != null && workingRadiusKmLatitude.trim().isNotEmpty) {
        bodyMap["workingRadiusKmLatitude"] = workingRadiusKmLatitude.trim();
      }
      if (workingRadiusKmLongitude != null && workingRadiusKmLongitude.trim().isNotEmpty) {
        bodyMap["workingRadiusKmLongitude"] = workingRadiusKmLongitude.trim();
      }
      if (workingAddress != null && workingAddress.trim().isNotEmpty) {
        bodyMap["workingAddress"] = workingAddress.trim();
      }

      FormData formData = FormData.fromMap(bodyMap);

      if (avatarPath != null && avatarPath.isNotEmpty) {
        final file = File(avatarPath);
        if (await file.exists()) {
          String fileName = file.path.split('/').last;
          var mimeType = lookupMimeType(file.path);
          formData.files.add(
            MapEntry(
              "avatar",
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: MediaType.parse(
                  mimeType ?? "application/octet-stream",
                ),
              ),
            ),
          );
        }
      }

      if (bodyMap.isEmpty && formData.files.isEmpty) {
        return {"success": true};
      }

      final response = await _apiServices.patchServices(
        url: url,
        body: formData,
      );

      return response;
    } catch (e) {
      errorLog('TechnicianProfileEditRepository.updateAccount error', e);
    }
    return null;
  }
}
