import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/customer_activity_response.dart';
import 'package:belwork/services/repository/customer_activity_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class CustomerActivityNotifier
    extends StateNotifier<AsyncValue<List<CustomerJobItem>>> {
  final CustomerActivityRepository _repository =
      CustomerActivityRepository.instance;

  CustomerActivityNotifier() : super(const AsyncValue.data([])) {
    fetchCustomerJobs();
  }

  Future<void> fetchCustomerJobs() async {
    final token = await StorageServices.instance.getToken();
    if (token.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getCustomerAllJobs();
      if (response != null && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('CustomerActivityNotifier.fetchCustomerJobs', e);
      state = AsyncValue.error(e, st);
    }
  }
}

final customerActivityProvider = StateNotifierProvider<
    CustomerActivityNotifier, AsyncValue<List<CustomerJobItem>>>(
  (ref) => CustomerActivityNotifier(),
);
