import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/modules/account/account_control.dart';
import 'package:videoflow/modules/account/account_page.dart';
import 'package:videoflow/modules/account/qr_login/auth/kwai.dart';
import 'package:videoflow/modules/account/qr_login/auth/kwai_shop.dart';
import 'package:videoflow/modules/indexed/indexed_control.dart';
import 'package:videoflow/modules/indexed/indexed_page.dart';
import 'package:videoflow/modules/task/task_control.dart';
import 'package:videoflow/modules/task/task_page.dart';
import 'package:videoflow/modules/set/set_control.dart';
import 'package:videoflow/modules/set/set_page.dart';
import 'package:videoflow/utils/route_path.dart';
import 'package:videoflow/modules/account/qr_login/qr_login_page.dart';
import 'package:videoflow/modules/account/qr_login/qr_login_control.dart';
import 'package:videoflow/modules/debug/hive_debug_page.dart';

class MenuItem {
  final String title;
  final int index;
  final IconData icon;
  final String routeName;
  MenuItem({
    required this.title,
    required this.index,
    required this.icon,
    required this.routeName,
  });
}

class AppPages {
  AppPages._();
  static final Map<String, MenuItem> menuItems = {
    RoutePath.account: MenuItem(
      title: '账号',
      index: 0,
      icon: Icons.person,
      routeName: RoutePath.account,
    ),
    RoutePath.task: MenuItem(
      title: '任务',
      index: 1,
      icon: Icons.task,
      routeName: RoutePath.task,
    ),
    RoutePath.settings: MenuItem(
      title: '设置',
      index: 2,
      icon: Icons.settings,
      routeName: RoutePath.settings,
    ),
    RoutePath.hiveDebug: MenuItem(
      title: '调试',
      index: 3,
      icon: Icons.bug_report,
      routeName: RoutePath.hiveDebug,
    ),
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
    GetPage(
      name: RoutePath.kwaiQrLogin,
      page: () => const KuaishouQrLoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => KuaiShouQrLoginControl(KwaiQrSession()));
      }),
    ),
    GetPage(
      name: RoutePath.shopQrLogin,
      page: () => const KuaishouQrLoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => KuaiShouQrLoginControl(KwaiShopQrSession()));
      }),
    ),
    GetPage(name: RoutePath.hiveDebug, page: () => const HiveDebugPage()),
  ];
}
