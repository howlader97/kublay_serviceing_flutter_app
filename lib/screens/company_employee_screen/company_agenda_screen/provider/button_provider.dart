import 'package:flutter_riverpod/flutter_riverpod.dart';

final buttonProvider=NotifierProvider<ButtonNotifier,int>(
  ButtonNotifier.new
);

 class ButtonNotifier extends Notifier<int>{
  @override
  int build() => 0;
  void select (int index){
    state = index;
  }
 }