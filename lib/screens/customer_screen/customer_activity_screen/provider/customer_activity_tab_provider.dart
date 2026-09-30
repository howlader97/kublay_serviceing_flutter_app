import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerActivityTabProvider = NotifierProvider<CustomerActivityTabNotifier, int>(
  CustomerActivityTabNotifier.new,
);

class CustomerActivityTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}
