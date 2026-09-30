import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/side_content_data_model.dart';
import 'package:belwork/screens/base_screen/faq_screen/models/f_a_q_screen_data_model.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class BaseRepository {
  /////////////// constructor
  BaseRepository._privateConstructor();
  static final BaseRepository _instance = BaseRepository._privateConstructor();
  static BaseRepository get instance => _instance;

  /////////////// object
  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  //////////////// function
  Future<SideContentDataModel?> termsAndConditions() async {
    try {
      var response = await _apiServices.getServices(_api.termsAndConditions);
      if (response != null && response["data"] != null) {
        dynamic data = response["data"];
        if (data is List && data.isNotEmpty) {
          data = data.first;
        }
        if (data is Map) {
          return SideContentDataModel.fromJson(data);
        }
      }
    } catch (e) {
      errorLog("termsAndConditions repo", e);
    }
    return null;
  }

  Future<SideContentDataModel?> aboutUs() async {
    try {
      var response = await _apiServices.getServices(_api.about);
      if (response != null && response["data"] != null) {
        dynamic data = response["data"];
        if (data is List && data.isNotEmpty) {
          data = data.first;
        }
        if (data is Map) {
          return SideContentDataModel.fromJson(data);
        }
      }
    } catch (e) {
      errorLog("aboutUs repo", e);
    }
    return null;
  }

  Future<SideContentDataModel?> privacyPolicy() async {
    try {
      var response = await _apiServices.getServices(_api.privacyPolicy);
      if (response != null && response["data"] != null) {
        dynamic data = response["data"];
        if (data is List && data.isNotEmpty) {
          data = data.first;
        }
        if (data is Map) {
          return SideContentDataModel.fromJson(data);
        }
      }
    } catch (e) {
      errorLog("privacyPolicy repo", e);
    }
    return null;
  }

  Future<List<FAQScreenDataModel>> getAllFaq() async {
    List<FAQScreenDataModel> listOfFaqData = [];
    try {
      var response = await _apiServices.getServices(_api.faq);
      if (response != null) {
        if (response["data"] is List) {
          for (var element in response["data"]) {
            listOfFaqData.add(FAQScreenDataModel.fromJson(element));
          }
        }
      }
    } catch (e) {
      errorLog("getAllFaq", e);
    }
    return listOfFaqData;
  }
}
