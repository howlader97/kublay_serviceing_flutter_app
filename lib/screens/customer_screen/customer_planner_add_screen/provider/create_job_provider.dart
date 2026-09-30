import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/services/repository/job_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class CreateJobNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final JobRepository _repository = JobRepository.instance;

  CreateJobNotifier() : super(const AsyncValue.data(null));

  Future<bool> submitJob({
    required String userId,
    required String categoryId,
    required String title,
    required String description,
    String? constructionYears,
    required String region,
    required String homeAsset,
    required String recurrenceType,
    required String wishRepairDate,
    required String budgetFee,
    required String address,
    String latitude = '',
    String longitude = '',
    List<String> imagePaths = const [],
    String? professionalId,
    String? urgency,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.createJob(
        userId: userId,
        categoryId: categoryId,
        title: title,
        description: description,
        constructionYears: constructionYears,
        region: region,
        homeAsset: homeAsset,
        recurrenceType: recurrenceType,
        wishRepairDate: wishRepairDate,
        budgetFee: budgetFee,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imagePaths: imagePaths,
        professionalId: professionalId,
        urgency: urgency,
      );

      if (response != null) {
        state = AsyncValue.data(response);
        AppSnackBar.instance.success("Job created successfully!");
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      errorLog('CreateJobNotifier.submitJob', e);
      state = AsyncValue.error(e, st);
      AppSnackBar.instance.error("Failed to create job");
      return false;
    }
  }
}

final createJobProvider =
    StateNotifierProvider<CreateJobNotifier, AsyncValue<dynamic>>(
  (ref) => CreateJobNotifier(),
);
