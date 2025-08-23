import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:videoflow/modules/account/account_control.dart';
import 'package:videoflow/modules/account/account_page.dart';
import 'package:videoflow/modules/task/task_control.dart';
import 'package:videoflow/modules/task/task_page.dart';
import 'package:videoflow/modules/set/set_control.dart';
import 'package:videoflow/modules/set/set_page.dart';
import 'package:videoflow/modules/const/event.dart';
import 'package:videoflow/utils/event_bus.dart';
import 'package:videoflow/routes/app_pages.dart';

class IndexedControl extends GetxController {
  RxList<MenuItem> items = RxList<MenuItem>([]);

  var index = 0.obs;
  RxList<Widget> pages = RxList<Widget>([
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
  ]);

  void setIndex(int i) {
    if (pages[i] is SizedBox) {
      switch (items[i].index) {
        case 0:
          Get.put(AccountControl());
          pages[i] = const AccountPage();
          break;
        case 1:
          Get.put(TaskControl());
          pages[i] = const TaskPage();
          break;
        case 2:
          Get.put(SetControl());
          pages[i] = const SetPage();
          break;
        default:
      }
    } else {
      if (index.value == i) {
        EventBus.instance.emit<int>(Event.bottomNavigationBarClicked, items[i].index);
      } }
    index.value = i;
  }

  @override
  void onInit() {
    items.value = AppPages.menuItems.values.toList();
    setIndex(0);
    super.onInit();
  }

}
