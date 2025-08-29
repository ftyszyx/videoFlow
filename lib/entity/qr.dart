import 'package:get/get_rx/get_rx.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:videoflow/utils/common.dart';

enum QRStatus { loading, unscanned, scanned, expired, failed, success }

enum QrPlatform { kwai, kwaiShop }

class QrAuthSession {
  String? userId;
  final QrPlatform platform; // 平台类型
  final String startUrl; // 开始扫码的url
  String? qrUrl;
  String? imageData;
  Rx<QRStatus> qrStatus = QRStatus.loading.obs;
  Browser? _browser;

  Future<void> afterRun(Browser browser, Page page) async {}

  Future<void> onRequest(Request request) async {}

  Future<void> onResponse(Response response) async {}

  Future<void> onStart(String userId) async {
    this.userId = userId;
    var (browser, page, _) = await CommonUtils.runBrowser(
      url: startUrl,
      forceShowBrowser: false,
      onRequest: onRequest,
      onResponse: onResponse,
    );
    _browser = browser;
    await afterRun(browser, page);
  }

  void onDestroy() {
    _browser?.close();
  }

  QrAuthSession({required this.platform, required this.startUrl});
}
