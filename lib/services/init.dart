import 'package:get/get.dart';
import 'account_service.dart';
import 'task_service.dart';
import 'web_clone_service.dart';
import 'app_config_service.dart';
import 'logger.dart';
import 'resource_service.dart';
import 'package:web_cloner/utils/event_bus.dart';
import 'package:web_cloner/modules/core/event.dart';

class ServiceManager {
  static Future<void> init() async {
    await Get.put(AppConfigService()).init();
    await logger.initialize();
    await Get.put(ResourceService()).init();
    await Get.put(AccountService()).init();
    await Get.put(TaskService()).init();
    await Get.put(WebCloneService()).init();
    WebCloneService.instance.startLoop();
  }

  static Future<void> initWithProgress() async {
    EventBus.instance.emit(Event.loadingProgress, (0.1, '检测资源版本'));
    await ResourceService.instance.checkResource();
    EventBus.instance.emit(Event.loadingProgress, (1.0, '完成'));
  }
}
