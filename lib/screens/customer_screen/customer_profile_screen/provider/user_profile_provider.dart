import 'package:belwork/models/user_profile_model.dart';
import 'package:belwork/services/repository/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  return await UserProfileRepository.instance.getUserProfile();
});