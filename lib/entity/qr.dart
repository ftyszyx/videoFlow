
import 'package:get/get_rx/get_rx.dart';

enum QRStatus {
  loading,
  unscanned,
  scanned,
  expired,
  failed,
}

enum KuaishouPlatform {
  kuaishou,
  shop;
}

class KwaiQrVariant {
  final KuaishouPlatform platform;
  final String qrHost;
  final String sid;
  Rx<QRStatus> qrStatus = QRStatus.loading.obs;
  final Map<String, String> otherParams;
  const KwaiQrVariant({
    required this.platform,
    required this.qrHost,
    required this.sid,
    required this.otherParams,
  });
}