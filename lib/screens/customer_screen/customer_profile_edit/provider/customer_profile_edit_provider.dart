import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/services/repository/user_profile_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class CustomerProfileEditNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final UserProfileRepository _repository = UserProfileRepository.instance;
  final Ref _ref;

  CustomerProfileEditNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? contact,
    String? address,
    String? avatarPath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.updateUserProfile(
        name: name,
        email: email,
        contact: contact,
        address: address,
        avatarPath: avatarPath,
      );

      if (response != null) {
        state = AsyncValue.data(response);
        // Refresh the profile state across the app
        _ref.invalidate(userProfileProvider);
        AppSnackBar.instance.success("Profile updated successfully!");
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      errorLog('CustomerProfileEditNotifier.updateProfile', e);
      state = AsyncValue.error(e, st);
      AppSnackBar.instance.error("Failed to update profile");
      return false;
    }
  }
}

final customerProfileEditProvider = StateNotifierProvider<
    CustomerProfileEditNotifier, AsyncValue<dynamic>>(
  (ref) => CustomerProfileEditNotifier(ref),
);
