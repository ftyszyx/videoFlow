import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TaskControl extends GetxController with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 1, vsync: this);
  }
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
