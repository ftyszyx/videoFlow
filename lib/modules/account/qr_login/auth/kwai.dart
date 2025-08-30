import 'dart:convert';

import 'package:puppeteer/puppeteer.dart' as pup;
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/utils/logger.dart';

class KwaiQrSession extends QrAuthSession {
  String get host => "https://id.kuaishou.com";
  KwaiQrSession({
    super.platform = VideoPlatform.kwai,
    super.startUrl = "https://www.kuaishou.com/?isHome=1",
  });

  @override
  Future<void> afterRun() async {
    if (browser == null) {
      return;
    }
    final page = browser!.page!;
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
  Future<void> onRequest(pup.Request request) async {
    await super.onRequest(request);
  }

  @override
  Future<void> onResponse(pup.Response response) async {
    await super.onResponse(response);
    final url = response.request.url;
    // logger.i("KwaiQrSession onResponse: $url");
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
      } else if (url.contains("$host/pass/kuaishou/login/qr/callback")) {
        final jsonData = jsonDecode(await response.text);
        final resCode = jsonData['result'];
        if (resCode == 1) {
          logger.i("login success:${jsonEncode(jsonData)}");
          final cookies = await browser!.page!.cookies();
          if (cookies.isNotEmpty) {
            platformInfo.cookie = {};
            for (var cookie in cookies) {
              platformInfo.cookie![cookie.name] = cookie.value;
            }
            logger.i("updatePlatformInfo:${platformInfo.toString()}");
            await AccountService.instance.updatePlatformInfo(
              userId!,
              platformInfo,
            );
            qrStatus.value = QRStatus.success;
          }
        }
      }
    } catch (e, s) {
      logger.e("KwaiQrSession onResponse error", error: e, stackTrace: s);
    }
  }
}
