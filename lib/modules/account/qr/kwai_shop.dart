import 'package:videoflow/entity/qr.dart';
import 'package:puppeteer/puppeteer.dart' as pup;
import 'package:videoflow/modules/account/qr/kwai.dart';

class KwaiShopQrSession extends KwaiQrSession {
  @override
  String get host => "https://id.kwaixiaodian.com";
  KwaiShopQrSession()
    : super(
        platform: QrPlatform.kwaiShop,
        startUrl: "https://login.kwaixiaodian.com/?biz=zone",
      );

  @override
  Future<void> afterRun(pup.Browser browser, pup.Page page) async {}
}
