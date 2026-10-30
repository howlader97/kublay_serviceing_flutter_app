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

  Future<bool> completeJob(String jobId) async {
    try {
      final updatedItem = await _repository.completeCustomerJob(jobId);
      if (updatedItem != null) {
        state.whenData((currentList) {
          final newList = currentList.map((item) {
            if (item.id == jobId) {
              if (updatedItem.user == null && item.user != null) {
                return CustomerJobItem(
                  id: updatedItem.id,
                  userId: updatedItem.userId,
                  professionalId: updatedItem.professionalId,
                  categoryId: updatedItem.categoryId,
                  title: updatedItem.title,
                  description: updatedItem.description,
                  constructionYears: updatedItem.constructionYears,
                  region: updatedItem.region,
                  homeAsset: updatedItem.homeAsset,
                  status: updatedItem.status,
                  recurrenceType: updatedItem.recurrenceType,
                  urgency: updatedItem.urgency,
                  wishRepairDate: updatedItem.wishRepairDate,
                  budgetFee: updatedItem.budgetFee,
                  address: updatedItem.address,
                  latitude: updatedItem.latitude,
                  longitude: updatedItem.longitude,
                  images: updatedItem.images,
                  createdAt: updatedItem.createdAt,
                  updatedAt: updatedItem.updatedAt,
                  user: item.user,
                );
              }
              return updatedItem;
            }
            return item;
          }).toList();
          state = AsyncValue.data(newList);
        });
        return true;
      }
    } catch (e) {
      errorLog('CustomerActivityNotifier.completeJob', e);
    }
    return false;
  }
}

final customerActivityProvider = StateNotifierProvider<
    CustomerActivityNotifier, AsyncValue<List<CustomerJobItem>>>(
  (ref) => CustomerActivityNotifier(),
);
