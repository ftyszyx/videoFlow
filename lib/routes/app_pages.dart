import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/modules/account/account_control.dart';
import 'package:videoflow/modules/account/account_page.dart';
import 'package:videoflow/modules/indexed/indexed_control.dart';
import 'package:videoflow/modules/indexed/indexed_page.dart';
import 'package:videoflow/modules/task/task_control.dart';
import 'package:videoflow/modules/task/task_page.dart';
import 'package:videoflow/modules/set/set_control.dart';
import 'package:videoflow/modules/set/set_page.dart';
import 'package:videoflow/utils/route_path.dart';

class MenuItem {
  final String title;
  final int index;
  final IconData icon;
  MenuItem({required this.title, required this.index, required this.icon});
}

class AppPages {
  AppPages._();
  static final Map<String, MenuItem> menuItems = {
    RoutePath.account: MenuItem(title: 'Account', index: 0, icon: Icons.person),
    RoutePath.task: MenuItem(title: 'Task', index: 1, icon: Icons.task),
    RoutePath.settings: MenuItem(title: 'Settings', index: 2, icon: Icons.settings),
  };
  static final routes = [
    GetPage(
      name: RoutePath.indexed,
      page: () => const IndexedPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IndexedControl());
      }),
    ),
    GetPage(
      name: RoutePath.account,
      page: () => const AccountPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AccountControl());
      }),
    ),
    GetPage(
      name: RoutePath.task,
      page: () => const TaskPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TaskControl());
      }),
    ),
    GetPage(
      name: RoutePath.settings,
      page: () => const SetPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SetControl());
      }),
    ),
  ];
}
