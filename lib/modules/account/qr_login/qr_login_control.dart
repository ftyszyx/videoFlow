import 'package:get/get.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/utils/base_control.dart';

class KuaiShouQrLoginControl extends BaseControl {
  final QrAuthSession _session;
  QrAuthSession get session => _session;
  String? accountId;
  KuaiShouQrLoginControl(this._session);

  Worker? _statusWorker;

  @override
  void onInit() {
    super.onInit();
    accountId = Get.parameters['id'];
    _statusWorker = ever<QRStatus>(
      _session.qrStatus,
      (status) {
        if (status == QRStatus.success) {
          if (Get.key.currentState?.canPop() == true) Get.back<void>();
        }
      },
    );
    _session.onStart(accountId!);
  }

  @override
  void onClose() {
    _statusWorker?.dispose();
    _session.onDestroy();
    super.onClose();
  }

  void loadQrCode() async {
    await _session.onStart(accountId!);
  }
}
