import 'package:get/get_rx/get_rx.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/models/db/platform_info.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';

enum QRStatus { loading, unscanned, scanned, expired, failed, success }

class QrAuthSession {
  String? userId;
  final VideoPlatform platform; // 平台类型
  final String startUrl; // 开始扫码的url
  String? qrUrl;
  String? imageData;
  Rx<QRStatus> qrStatus = QRStatus.loading.obs;
  BrowserSession? _browser;
  BrowserSession? get browser => _browser;
  late PlatformInfo _platformInfo;
  PlatformInfo get platformInfo => _platformInfo;

  Future<void> afterRun() async {}

  Future<void> onRequest(Request request) async {
    // logger.i('onRequest: ${request.url}');
  }

  Future<void> onResponse(Response response) async {
    // logger.i('onResponse: ${response.url}');
  }

  Future<void> onStart(String userId) async {
    this.userId = userId;
    try {
      _browser = await CommonUtils.runBrowser(
        url: startUrl,
        forceShowBrowser: true,
        onRequest: onRequest,
        onResponse: onResponse,
      );
      await afterRun();
    } catch (e, s) {
      logger.e("onStart error", error: e, stackTrace: s);
    }
  }

  Future<void> onLoginOk(List<String> urls) async {
    logger.i("wait for cookies:${urls.join(",")}");
    await Future.delayed(const Duration(seconds: 3));
    final pageIns = browser!.page!;
    final cookies = await pageIns.cookies(urls: urls);
    if (cookies.isNotEmpty) {
      platformInfo.cookies = [];
      for (var cookie in cookies) {
        logger.i("add cookie: ${cookie.name.toString()}");
        platformInfo.cookies!.add(cookie);
      }
      logger.i("updatePlatformInfo:${platformInfo.toString()}");
      await AccountService.instance.updatePlatformInfo(userId!, platformInfo);
      qrStatus.value = QRStatus.success;
    }
  }

  void onDestroy() {
    _browser?.close();
  }

  QrAuthSession({required this.platform, required this.startUrl}) {
    _platformInfo = PlatformInfo(platform: platform);
  }
}
