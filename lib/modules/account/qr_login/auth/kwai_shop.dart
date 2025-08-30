import 'package:videoflow/entity/common.dart';
import 'package:videoflow/modules/account/qr_login/auth/kwai.dart';

class KwaiShopQrSession extends KwaiQrSession {
  @override
  String get host => "https://id.kwaixiaodian.com";
  KwaiShopQrSession()
    : super(
        platform: VideoPlatform.kwaiShop,
        startUrl: "https://login.kwaixiaodian.com/?biz=zone",
      );

  @override
  Future<void> afterRun() async {}
}
