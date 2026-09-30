import 'package:flutter_riverpod/flutter_riverpod.dart';

final technicianHomeTabProvider = NotifierProvider<ButtonNotifierProvider, int>(
  ButtonNotifierProvider.new,
);

class ButtonNotifierProvider extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}
