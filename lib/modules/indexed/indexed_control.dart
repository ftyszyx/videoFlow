import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:videoflow/modules/const/event.dart';
import 'package:videoflow/utils/event_bus.dart';
import 'package:videoflow/routes/app_pages.dart';

class IndexedControl extends GetxController {
  RxList<MenuItem> items = RxList<MenuItem>([]);

  var index = 0.obs;
  RxList<Widget> pages = RxList<Widget>([]);
  Widget _buildPageForIndex(int i) {
    final routeName = AppPages.menuItems.entries.firstWhere((e)=>e.value.index==i).key;
    final gp = AppPages.routes.firstWhere((p) => p.name == routeName);
    gp.binding?.dependencies();
    return gp.page();
  }

  void setIndex(int i) {
    if (pages[i] is SizedBox) {
      pages[i] = _buildPageForIndex(i);
    } else {
      if (index.value == i) {
        //回到顶部刷新
        EventBus.instance.emit<int>(
          Event.bottomNavigationBarClicked,
          items[i].index,
        );
      }
    }
    index.value = i;
  }

  @override
  void onInit() {
    items.value = AppPages.menuItems.values.toList();
    pages.assignAll(List<Widget>.generate(items.length, (_) => const SizedBox()));
    setIndex(0);
    super.onInit();
  }
}
