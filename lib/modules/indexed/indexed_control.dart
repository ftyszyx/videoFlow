import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:videoflow/modules/const/event.dart';
import 'package:videoflow/utils/event_bus.dart';
import 'package:videoflow/routes/app_pages.dart';

class IndexedControl extends GetxController {
  late final List<MenuItem> items;
  final RxInt index = 0.obs;
  late final List<Widget?> _pages;

  // 预构建 index -> GetPage 的映射，避免每次线性查找
  late final Map<int, GetPage<dynamic>> _indexToPage;

  // 对外暴露只读的 pages，用于 IndexedStack children
  List<Widget> get pages =>
      List<Widget>.generate(items.length, (i) => _pages[i] ?? const SizedBox());

  @override
  void onInit() {
    super.onInit();
    // 将菜单项按 index 排序，确保顺序稳定
    items = AppPages.menuItems.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    // 构建 index -> GetPage 映射
    _indexToPage = {
      for (final gp in AppPages.routes)
        if (AppPages.menuItems[gp.name]?.index != null)
          AppPages.menuItems[gp.name]!.index: gp,
    };

    // 初始化页面缓存
    _pages = List<Widget?>.filled(items.length, null, growable: false);
    setIndex(0);
  }

  void setIndex(int i) {
    if (i < 0 || i >= items.length) return;
    if (index.value == i) {
      _emitTapCurrent(i);
    }
    _ensurePageBuilt(i);
    index.value = i;
  }

  // 主动刷新当前页
  void refreshCurrent() => _emitTapCurrent(index.value);

  void _ensurePageBuilt(int i) {
    if (_pages[i] != null) return;
    final gp = _indexToPage[items[i].index];
    if (gp == null) {
      _pages[i] = const SizedBox();
      return;
    }
    // 首次构建时才注入依赖
    gp.binding?.dependencies();
    _pages[i] = gp.page();
  }

  void _emitTapCurrent(int i) {
    EventBus.instance.emit<int>(
      Event.bottomNavigationBarClicked,
      items[i].index,
    );
  }
}
