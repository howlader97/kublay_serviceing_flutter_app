import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/side_content_data_model.dart';
import 'package:belwork/services/repository/base_repository.dart';
import 'package:belwork/utils/app_log.dart';

final termsAndConditionsScreenProvider = StateNotifierProvider<
    _TermsAndConditionsScreenProvider,
    AsyncValue<SideContentDataModel?>>(
  (ref) => _TermsAndConditionsScreenProvider(),
);

class _TermsAndConditionsScreenProvider
    extends StateNotifier<AsyncValue<SideContentDataModel?>> {
  final BaseRepository _repo = BaseRepository.instance;
  _TermsAndConditionsScreenProvider() : super(const AsyncLoading()) {
    onAppLoading();
  }

  Future<void> onAppLoading() async {
    try {
      var response = await _repo.termsAndConditions();
      state = AsyncData(response);
    } catch (e, stackTrace) {
      errorLog("onAppLoading", e);
      state = AsyncError("onAppLoading provider", stackTrace);
    }
  }
}
