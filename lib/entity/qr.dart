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
    _browser = await CommonUtils.runBrowser(
      url: startUrl,
      forceShowBrowser: false,
      onRequest: onRequest,
      onResponse: onResponse,
    );
    await afterRun();
  }

  Future<void> onLoginOk() async {
    final cookies = await browser!.page!.cookies();
    if (cookies.isNotEmpty) {
      platformInfo.cookies = [];
      for (var cookie in cookies) {
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
