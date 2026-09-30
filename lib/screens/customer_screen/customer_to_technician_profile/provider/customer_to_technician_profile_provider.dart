import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/professional_profile_details_model.dart';
import 'package:belwork/services/repository/professional_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:flutter_riverpod/legacy.dart';

final customerToTechnicianProfileProvider = StateNotifierProvider.autoDispose
    .family<CustomerToTechnicianProfileNotifier,
        AsyncValue<ProfessionalProfileDetailsData?>, String?>((ref, professionalId) {
  return CustomerToTechnicianProfileNotifier(professionalId);
});

class CustomerToTechnicianProfileNotifier
    extends StateNotifier<AsyncValue<ProfessionalProfileDetailsData?>> {
  final String? professionalId;
  final ProfessionalRepository _repository = ProfessionalRepository.instance;

  CustomerToTechnicianProfileNotifier(this.professionalId)
      : super(const AsyncLoading()) {
    fetchProfileDetails();
  }

  Future<void> fetchProfileDetails() async {
    if (professionalId == null || professionalId!.isEmpty) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    try {
      final response = await _repository.getProfessionalProfileDetails(
        customProfessionalId: professionalId,
      );

      if (response != null && response.data != null) {
        state = AsyncData(response.data);
      } else {
        state = const AsyncData(null);
      }
    } catch (e, stackTrace) {
      errorLog('CustomerToTechnicianProfileNotifier.fetchProfileDetails', e);
      state = AsyncError(e, stackTrace);
    }
  }
}
