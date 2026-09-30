import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/side_content_data_model.dart';
import 'package:belwork/services/repository/base_repository.dart';
import 'package:belwork/utils/app_log.dart';

final aboutUsScreenProvider = StateNotifierProvider<
    _AboutUsScreenProvider,
    AsyncValue<SideContentDataModel?>>(
  (ref) => _AboutUsScreenProvider(),
);

class _AboutUsScreenProvider
    extends StateNotifier<AsyncValue<SideContentDataModel?>> {
  final BaseRepository _repo = BaseRepository.instance;
  _AboutUsScreenProvider() : super(const AsyncLoading()) {
    onAppLoading();
  }

  Future<void> onAppLoading() async {
    try {
      var response = await _repo.aboutUs();
      state = AsyncData(response);
    } catch (e, stackTrace) {
      errorLog("_AboutUsScreenProvider", e);
      state = AsyncError("_AboutUsScreenProvider provider", stackTrace);
    }
  }
}
