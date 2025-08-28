import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/utils/logger.dart';
import 'parsers/kuaishou_parser.dart';
import 'package:videoflow/entity/common.dart';

import 'package:get/get.dart';

class UrlParseService extends GetxService {
  static UrlParseService get instance => Get.find<UrlParseService>();
  final RxMap<String, VideoTask> _parseTasks = <String, VideoTask>{}.obs;

  Future<void> init() async {
    startParseLoop();
  }

  bool addParseTask(VideoTask task) {
    if (!_parseTasks.containsKey(task.id)) {
      _parseTasks[task.id] = task;
      return true;
    }
    return false;
  }

  Future<void> startParseLoop() async {
    while (true) {
      for (var task in _parseTasks.values) {
        if (task.status == TaskStatus.waitForParse) {
          _startParseUrl(task);
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Parses a share text/URL to extract video details like title and m3u8 URL.
  Future<void> _startParseUrl(VideoTask task) async {
    try {
      if (task.shareLink.contains('m.tb.cn')) {
        task.errMsg = '不支持的平台';
        task.status = TaskStatus.parseFailed;
        return;
      } else if (task.shareLink.contains('v.kuaishou.com')) {
        await KuaishouParser.parse(task);
      } else {
        task.errMsg = '不支持的平台';
        task.status = TaskStatus.parseFailed;
        return;
      }
    } catch (e, s) {
      logger.e('Failed to parse url', error: e, stackTrace: s);
      task.errMsg = '解析失败';
      task.status = TaskStatus.parseFailed;
      return;
    }
  }

  void stopParse(String taskId) {
    if (_parseTasks.containsKey(taskId)) {
      _parseTasks[taskId]!.status = TaskStatus.pause;
      _parseTasks.remove(taskId);
    }
  }

  void stopAllParse() {
    for (var task in _parseTasks.values) {
      stopParse(task.id);
    }
  }

  void dispose() {
    stopAllParse();
    _parseTasks.clear();
  }
}
