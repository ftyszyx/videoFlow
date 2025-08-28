import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/utils/logger.dart';
import 'parsers/kuaishou_parser.dart';
import 'package:videoflow/entity/url_parse.dart';
import 'package:videoflow/entity/error.dart';

import 'package:get/get.dart';

class UrlParseService extends GetxService {
  var isParsing = false.obs;
  static UrlParseService get instance => Get.find<UrlParseService>();
  init() {
    isParsing.value = false;
  }

  void stopParsing() {
    isParsing.value = false;
  }

  /// Parses a share text/URL to extract video details like title and m3u8 URL.
  Future<CommonResult<void>> parseUrl(VideoTassk task) async {
    if (isParsing.value) {
      return CommonResult(success: false, error: '正在解析中，请稍后再试');
    }
    isParsing.value = true;
    needStop() {
      if (!isParsing.value) {
        return true;
      }
      return false;
    }
    try {
      if (shareText.contains('m.tb.cn')) {
        return CommonResult(success: false, error: '不支持的平台');
      } else if (shareText.contains('v.kuaishou.com')) {
        return await KuaishouParser.parse(
          userId: userId,
          shareText: shareText,
          needStop: needStop,
        );
      } else {
        return CommonResult(success: false, error: '不支持的平台');
      }
    } catch (e, s) {
      logger.e('Failed to parse url', error: e, stackTrace: s);
      return CommonResult(success: false, error: '解析失败');
    } finally {
      isParsing.value = false;
    }
  }
}
