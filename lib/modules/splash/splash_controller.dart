import 'package:get/get.dart';
import 'package:web_cloner/modules/core/event.dart';
import 'package:web_cloner/routes/app_pages.dart';
import 'package:web_cloner/services/logger.dart';
import 'package:web_cloner/services/init.dart';
import 'package:web_cloner/utils/event_bus.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxString message = 'Initializing...'.obs;

  @override
  void onInit() {
    super.onInit();
    EventBus.instance.listenTyped<(double, String)>(
      Event.loadingProgress,
      onLoadingProgress,
    );
    _start();
  }

  void onLoadingProgress((double, String) data) {
    final (progressArg, messageArg) = data;
    progress.value = progressArg.clamp(0, 1);
    message.value = messageArg;
  }

  Future<void> _start() async {
    try {
      await ServiceManager.initWithProgress();
      Get.offAllNamed(Routes.home);
    } catch (e, s) {
      logger.error('初始化失败：$e', error: e, stackTrace: s);
      message.value = '初始化失败：$e';
    }
  }
}
