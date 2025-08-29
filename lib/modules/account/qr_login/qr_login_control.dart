import 'package:get/get.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/utils/base_control.dart';

class KuaiShouQrLoginControl extends BaseControl {
  final QrAuthSession _session;
  QrAuthSession get session => _session;
  String? accountId;
  KuaiShouQrLoginControl(this._session);

  @override
  void onInit() {
    super.onInit();
    accountId = Get.parameters['id'];
    _session.onStart(accountId!);
  }

  @override
  void onClose() {
    super.onClose();
    _session.onDestroy();
  }

  String getPlatformTitle() {
    switch (_session.platform) {
      case QrPlatform.kwai:
        return "快手";
      case QrPlatform.kwaiShop:
        return "小店";
    }
  }

  void loadQrCode() async {
    await _session.onStart(accountId!);
  }
}
