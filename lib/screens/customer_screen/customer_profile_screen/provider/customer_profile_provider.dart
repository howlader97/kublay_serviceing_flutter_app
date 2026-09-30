import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/user_profile_model.dart';
import 'package:belwork/services/repository/user_profile_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserData?>> {
  final UserProfileRepository _repository = UserProfileRepository.instance;

  UserProfileNotifier() : super(const AsyncValue.data(null)) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = await StorageServices.instance.getToken();
    if (token.trim().isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getUserProfile();
      if (response != null && response.data != null) {
        state = AsyncValue.data(response.data);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      errorLog('UserProfileNotifier.fetchProfile', e);
      state = AsyncValue.error(e, st);
    }
  }
  void clearProfile() {
    state = const AsyncValue.data(null);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier,
    AsyncValue<UserData?>>(
  (ref) => UserProfileNotifier(),
);
