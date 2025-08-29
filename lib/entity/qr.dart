import 'package:get/get_rx/get_rx.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:videoflow/entity/common.dart';
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
  BrowserSession? _browser;
  BrowserSession? get browser => _browser;

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

  void onDestroy() {
    _browser?.close();
  }

  QrAuthSession({required this.platform, required this.startUrl});
}
