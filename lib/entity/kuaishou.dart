class QrStartData {
  final int? expireTime;
  final String? qrUrl;
  final String? qrLoginSignature;
  final String? imageData;
  final String? callback;
  final String? qrLoginToken;
  final String? sid;
  QrStartData({
    this.expireTime,
    this.qrUrl,
    this.qrLoginSignature,
    this.imageData,
    this.callback,
    this.qrLoginToken,
    this.sid,
  });
  factory QrStartData.fromJson(Map<String, dynamic> json) {
    return QrStartData(
      expireTime: json['expireTime'] is int
          ? json['expireTime'] as int
          : (json['expireTime'] is String
                ? int.tryParse(json['expireTime'])
                : null),
      qrUrl: json['qrUrl'] as String?,
      qrLoginSignature: json['qrLoginSignature'] as String?,
      imageData: json['imageData'] as String?,
      callback: json['callback'] as String?,
      qrLoginToken: json['qrLoginToken'] as String?,
      sid: json['sid'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'expireTime': expireTime,
      'qrUrl': qrUrl,
      'qrLoginSignature': qrLoginSignature,
      'imageData': imageData,
      'callback': callback,
      'qrLoginToken': qrLoginToken,
      'sid': sid,
    };
  }
}

class QrAcceptResultData {
  final String? qrToken;
  final String? sid;
  QrAcceptResultData({this.qrToken, this.sid});
  factory QrAcceptResultData.fromJson(Map<String, dynamic> json) {
    return QrAcceptResultData(
      qrToken: json['qrToken'] as String?,
      sid: json['sid'] as String?,
    );
  }
}

enum KuaishouPlatform {
  kuaishou,
  shop;
}

class KwaiQrVariant {
  final KuaishouPlatform platform;
  final String qrHost;
  final String sid;
  final Map<String, String> otherParams;
  const KwaiQrVariant({
    required this.platform,
    required this.qrHost,
    required this.sid,
    required this.otherParams,
  });
}

const kuaishouQrVariant = KwaiQrVariant(
  platform: KuaishouPlatform.kuaishou,
  qrHost: "https://id.kuaishou.com",
  sid: "kuaishou.server.webday7",
  otherParams: {},
);
const shopQrVariant = KwaiQrVariant(
  platform: KuaishouPlatform.shop,
  qrHost: "https://id.kwaixiaodian.com",
  sid: "kuaishou.shop.b",
  otherParams: {
    "isWebSig4":"true"
  },
);
