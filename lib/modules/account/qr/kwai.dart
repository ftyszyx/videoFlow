import 'dart:convert';

import 'package:puppeteer/puppeteer.dart' as pup;
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';

class KwaiQrSession extends QrAuthSession {
  String get host => "https://id.kuaishou.com";
  KwaiQrSession({
    super.platform = QrPlatform.kwai,
    super.startUrl = "https://www.kuaishou.com/?isHome=1",
  });

  @override
  Future<void> afterRun(pup.Browser browser, pup.Page page) async {
    try {
      final loginText = await page.evaluate(
        'document.querySelector("p.user-default").innerText',
      );
      if (loginText == '登录') {
        await page.click('p.user-default');
      } else {
        logger.e("没找到登录按钮");
      }
    } catch (e, s) {
      logger.e("KwaiQrSession afterRun error", error: e, stackTrace: s);
    }
    qrStatus.value = QRStatus.loading;
  }

  @override
  Future<void> onRequest(pup.Request request) async {}

  @override
  Future<void> onResponse(pup.Response response) async {
    if (response.request.url.contains("$host/rest/c/infra/ks/qr/start")) {
      final jsonData = jsonDecode(await response.text);
      qrUrl = jsonData['qrUrl'];
      imageData = jsonData['imageData'];
      qrStatus.value = QRStatus.unscanned;
    } else if (response.request.url.contains(
      "$host/rest/c/infra/ks/qr/scanResult",
    )) {
      final jsonData = jsonDecode(await response.text);
      final resCode = jsonData['result'];
      if (resCode == 1) {
        qrStatus.value = QRStatus.scanned;
      } else if (resCode == 707) {
        qrStatus.value = QRStatus.expired;
      } else {
        qrStatus.value = QRStatus.failed;
      }
    } else if (response.request.url.contains(
      "$host/pass/kuaishou/login/qr/callback",
    )) {
      final jsonData = jsonDecode(await response.text);
      final resCode = jsonData['result'];
      if (resCode == 1) {
        qrStatus.value = QRStatus.success;
        final cookies = <String, String>{};
        for (var header in response.headers.entries) {
          if (header.key.toLowerCase() == "set-cookie") {
            CommonUtils.cookieAdd(cookies, header.value);
          }
        }
        if (cookies.isNotEmpty) {
          await AccountService.instance.updateKuaishouCookie(userId!, cookies);
        }
      }
    }
  }
}
