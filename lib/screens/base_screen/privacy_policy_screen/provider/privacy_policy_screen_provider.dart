import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/screens/base_screen/privacy_policy_screen/models/privacy_policy_data_model.dart';
import 'package:belwork/services/repository/base_repository.dart';
import 'package:belwork/utils/app_log.dart';

final privacyPolicyScreenProvider = StateNotifierProvider<
    _PrivacyPolicyScreenProvider,
    AsyncValue<PrivacyPolicyDataModel?>>(
  (ref) => _PrivacyPolicyScreenProvider(),
);

class _PrivacyPolicyScreenProvider
    extends StateNotifier<AsyncValue<PrivacyPolicyDataModel?>> {
  final BaseRepository _repo = BaseRepository.instance;
  _PrivacyPolicyScreenProvider() : super(const AsyncLoading()) {
    onAppLoading();
  }

  Future<void> onAppLoading() async {
    try {
      var response = await _repo.privacyPolicy();
      state = AsyncData(response);
    } catch (e, stackTrace) {
      errorLog("_PrivacyPolicyScreenProvider", e);
      state = AsyncError("_PrivacyPolicyScreenProvider provider", stackTrace);
    }
  }
}
