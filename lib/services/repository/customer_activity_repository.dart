import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/customer_activity_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class CustomerActivityRepository {
  CustomerActivityRepository._privateConstructor();
  static final CustomerActivityRepository _instance =
      CustomerActivityRepository._privateConstructor();
  static CustomerActivityRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;


  Future<CustomerActivityResponse?> getCustomerAllJobs([String? userId]) async {
    try {
      final responseData =
          await _apiServices.getServices(_api.customerAllJobs);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return CustomerActivityResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('CustomerActivityRepository.getCustomerAllJobs', e);
      return null;
    }
  }

  Future<CustomerJobItem?> completeCustomerJob(String jobId) async {
    try {
      final responseData = await _apiServices.patchServices(
        url: _api.completeJob(jobId),
      );
      if (responseData != null && responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          AppSnackBar.instance.success(responseData['message'].toString());
        }
        if (responseData['data'] != null &&
            responseData['data'] is Map<String, dynamic>) {
          return CustomerJobItem.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      errorLog('CustomerActivityRepository.completeCustomerJob', e);
      return null;
    }
  }
}
