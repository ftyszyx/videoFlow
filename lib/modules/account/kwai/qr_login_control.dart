import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:videoflow/entity/qr.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/utils/base_control.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:videoflow/utils/requests/http_client.dart';
import 'package:videoflow/entity/kuaishou.dart';

class KuaiShouQrLoginControl extends BaseControl {
  Rx<QRStatus> qrStatus = QRStatus.loading.obs;
  final KwaiQrVariant _variant;
  var qrStartData = QrStartData().obs;
  Timer? timer;
  String? accountId;
  KuaiShouQrLoginControl(this._variant);

  @override
  void onInit() {
    super.onInit();
    accountId = Get.parameters['id'];
    loadQrCode();
  }

  @override
  void onClose() {
    super.onClose();
    timer?.cancel();
  }

  String getPlatformTitle() {
    switch (_variant.platform) {
      case KuaishouPlatform.kuaishou:
        return "快手";
      case KuaishouPlatform.shop:
        return "小店";
    }
  }

  void startPoll() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (qrStatus.value == QRStatus.unscanned) {
        pollQrStatus();
      }
    });
  }

  void pollQrStatus() async {
    try {
      var dio = HttpClient.instance.dio;
      logger.i("do pull status");
      var result = await dio.post(
        "${_variant.qrHost}/rest/c/infra/ks/qr/scanResult",
        queryParameters: {
          "qrLoginToken": qrStartData.value.qrLoginToken,
          "qrLoginSignature": qrStartData.value.qrLoginSignature,
          "sid": _variant.sid,
          "channelType": "UNKNOWN",
          ..._variant.otherParams,
        },
        options: Options(responseType: ResponseType.json),
      );
      var resCode = result.data["result"];
      if (resCode == 707) {
        qrStatus.value = QRStatus.expired;
      } else if (resCode == 1) {
        qrStatus.value = QRStatus.scanned;
        var data = await acceptResult();
        if (data != null) {
          var isSuccess = await getCookies(data);
          if (isSuccess) {
            logger.i("login success");
            Get.back();
          }
        } else {
          qrStatus.value = QRStatus.failed;
        }
      } else {
        SmartDialog.showToast(result.data["message"]);
      }
    } catch (e, s) {
      SmartDialog.showToast(e.toString());
      logger.e("pollQrStatus error", error: e, stackTrace: s);
    }
  }

  Future<QrAcceptResultData?> acceptResult() async {
    try {
      var dio = HttpClient.instance.dio;
      var result = await dio.post(
        "${_variant.qrHost}/rest/c/infra/ks/qr/acceptResult",
        queryParameters: {
          "qrLoginToken": qrStartData.value.qrLoginToken,
          "qrLoginSignature": qrStartData.value.qrLoginSignature,
          "sid": _variant.sid,
          "channelType": "UNKNOWN",
          ..._variant.otherParams,
        },
      );
      var resCode = result.data["result"];
      if (resCode == 1) {
        var data = QrAcceptResultData.fromJson(result.data);
        return data;
      } else {
        SmartDialog.showToast(result.data["message"]);
        return null;
      }
    } catch (e, s) {
      SmartDialog.showToast(e.toString());
      logger.e("acceptResult error", error: e, stackTrace: s);
      return null;
    }
  }

  Future<bool> getCookies(QrAcceptResultData qrAcceptResultData) async {
    try {
      var dio = HttpClient.instance.dio;
      var response = await dio.post(
        "${_variant.qrHost}/pass/kuaishou/login/qr/callback",
        queryParameters: {
          "qrToken": qrAcceptResultData.qrToken,
          "sid": _variant.sid,
          "channelType": "UNKNOWN",
          ..._variant.otherParams,
        },
        options: Options(responseType: ResponseType.json),
      );
      var data = response.data;
      var resCode = data["result"];
      if (resCode == 1) {
        var cookies = <String, String>{};
        var headerCookies = response.headers["set-cookie"];
        if (headerCookies != null) {
          for (var cookie in headerCookies) {
            CommonUtils.cookieAdd(cookies, cookie);
          }
        }
        if (cookies.isNotEmpty) {
          if (_variant.platform == KuaishouPlatform.kuaishou) {
          await AccountService.instance.updateKuaishouCookie(
              accountId!,
              cookies,
            );
          }
          if (_variant.platform == KuaishouPlatform.shop) {
            await AccountService.instance.updateXiaoDianCookie(
              accountId!,
              cookies,
            );
          }
        }
        return true;
      } else {
        SmartDialog.showToast(data["message"]);
        logger.e("getCookies error", error: data["message"]);
        return false;
      }
    } catch (e, s) {
      SmartDialog.showToast(e.toString());
      logger.e("getCookies error", error: e, stackTrace: s);
      return false;
    }
  }

  void loadQrCode() async {
    try {
      qrStatus.value = QRStatus.loading;
      var dio = HttpClient.instance.dio;
      var result = await dio.post(
        "${_variant.qrHost}/rest/c/infra/ks/qr/start",
        queryParameters: {
          "sid": _variant.sid,
          "channelType": "UNKNOWN",
          ..._variant.otherParams,
        },
        options: Options(responseType: ResponseType.json),
      );
      if (result.data["result"] != 1) {
        throw Exception(result.data["message"]);
      }
      qrStartData.value = QrStartData.fromJson(result.data);
      qrStatus.value = QRStatus.unscanned;
      startPoll();
    } catch (e, s) {
      SmartDialog.showToast(e.toString());
      logger.e("loadQrCode error", error: e, stackTrace: s);
      qrStatus.value = QRStatus.failed;
    }
  }
}
