import 'dart:convert';

import 'package:videoflow/entity/common.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:puppeteer/puppeteer.dart' as pup;
import 'package:videoflow/utils/logger.dart';

class KwaiShopQrSession extends QrAuthSession {
  String get host => "https://id.kwaixiaodian.com";
  KwaiShopQrSession()
    : super(
        platform: VideoPlatform.kwaiShop,
        startUrl: "https://login.kwaixiaodian.com/?biz=zone",
      );

  @override
  Future<void> afterRun() async {}

  @override
  Future<void> onResponse(pup.Response response) async {
    await super.onResponse(response);
    final url = response.request.url;
    try {
      if (url.contains("$host/rest/c/infra/ks/qr/start")) {
        final jsonData = jsonDecode(await response.text);
        qrUrl = jsonData['qrUrl'];
        imageData = jsonData['imageData'];
        qrStatus.value = QRStatus.unscanned;
        logger.i("get qrcode ok");
      } else if (url.contains("$host/rest/c/infra/ks/qr/scanResult")) {
        final jsonData = jsonDecode(await response.text);
        final resCode = jsonData['result'];
        if (resCode == 1) {
          qrStatus.value = QRStatus.scanned;
          logger.i("scan success:${jsonEncode(jsonData)}");
          var user = jsonData['user'];
          platformInfo.userId = user['user_id'].toString();
          platformInfo.userName = user['user_name'];
          platformInfo.headUrl = user['headurls'][0]['url'];
        } else if (resCode == 707) {
          qrStatus.value = QRStatus.expired;
        } else {
          qrStatus.value = QRStatus.failed;
        }
      } else if (url.contains("$host/pass/bid/web/sns/quickLoginByKsAuth")) {
        final jsonData = jsonDecode(await response.text);
        final resCode = jsonData['result'];
        if (resCode == 1) {
          logger.i("login ksauth:${jsonEncode(jsonData)}");
        }
      } else if (url.contains("https://login.kwaixiaodian.com/rest/infra/sts?authToken=")) {
        final jsonData = jsonDecode(await response.text);
        final code = jsonData["result"];
        if (code == 1) {
          logger.i("login auth ok:${jsonEncode(jsonData)}");
          await onLoginOk();
        }
      }
    } catch (e, s) {
      logger.e("KwaiShopQrSession onResponse error", error: e, stackTrace: s);
    }
  }
}
