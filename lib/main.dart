import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/modules/log/debug_log_page.dart';
import 'package:videoflow/routes/app_pages.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/services/download_service.dart';
import 'package:videoflow/services/task_servcie.dart';
import 'package:videoflow/services/url_parse/url_parse_service.dart';
import 'package:videoflow/utils/route_path.dart';
import 'package:videoflow/services/app_config_service.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/services/cover_style_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:videoflow/widgets/status/app_loading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();
  var appDocsDir = await getApplicationSupportDirectory();
  await Hive.initFlutter(
    (!Platform.isAndroid && !Platform.isIOS) ? appDocsDir.path : null,
  );
  await initServices();
  runApp(const MyApp());
}

Future initWindow() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(280, 280),
    center: true,
    title: "Video Flow",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Future initServices() async {
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(VideoTaskAdapter());
  Hive.registerAdapter(CoverStyleAdapter());
  CommonUtils.packageInfo = await PackageInfo.fromPlatform();
  await Get.put(AppConfigService()).init();
  await Get.put(AccountService()).init();
  await Get.put(UrlParseService()).init();
  await Get.put(CoverStyleService()).init();
  await Get.put(TaskService()).init();
  await Get.put(DownloadManagerService()).init();
  await logger.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color styleColor = Colors.blue;
    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic;
          darkColorScheme = darkDynamic;
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: styleColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: styleColor,
            brightness: Brightness.dark,
          );
        }
        return GetMaterialApp(
          title: "Video Flow",
          theme: ThemeData(colorScheme: lightColorScheme),
          darkTheme: ThemeData(colorScheme: darkColorScheme),
          themeMode: ThemeMode.light,
          initialRoute: RoutePath.indexed,
          getPages: AppPages.routes,
          //国际化
          locale: const Locale("zh", "CN"),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale("zh", "CN")],
          logWriterCallback: (text, {bool? isError}) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isError ?? false) {
                logger.e(text);
              } else {
                logger.i(text);
              }
            });
          },
          //debugShowCheckedModeBanner: false,
          navigatorObservers: [FlutterSmartDialog.observer],
          builder: FlutterSmartDialog.init(
            loadingBuilder: ((msg) => const AppLoadingWidget()),
            //字体大小不跟随系统变化
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Stack(
                children: [
                  //侧键返回
                  RawGestureDetector(
                    excludeFromSemantics: true,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (KeyEvent event) async {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.escape) {
                          // ESC退出全屏
                          // 如果处于全屏状态，退出全屏
                          if (!Platform.isAndroid && !Platform.isIOS) {
                            if (await windowManager.isFullScreen()) {
                              await windowManager.setFullScreen(false);
                              return;
                            }
                          }
                        }
                      },
                      child: child!,
                    ),
                  ),

                  //查看DEBUG日志按钮
                  //只在Debug、Profile模式显示
                  Visibility(
                    visible: !kReleaseMode,
                    child: Positioned(
                      right: 12,
                      bottom: 100 + context.mediaQueryViewPadding.bottom,
                      child: Opacity(
                        opacity: 0.4,
                        child: ElevatedButton(
                          child: const Text("DEBUG LOG"),
                          onPressed: () {
                            Get.bottomSheet(const DebugLogPage());
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
