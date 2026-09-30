import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/storage/storage_services.dart';

final rollSettingsProvider = StateProvider<int>((ref) => -1);

final userRoleNotifierProvider = StateNotifierProvider<UserRoleNotifier, AsyncValue<String>>((ref) {
  return UserRoleNotifier();
});

class UserRoleNotifier extends StateNotifier<AsyncValue<String>> {
  UserRoleNotifier() : super(const AsyncValue.loading()) {
    loadRole();
  }

  Future<void> loadRole() async {
    state = const AsyncValue.loading();
    try {
      final role = await StorageServices.instance.getAppRoll();
      state = AsyncValue.data(role);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setRole(String role) async {
    await StorageServices.instance.setAppRoll(role);
    state = AsyncValue.data(role);
  }
}
