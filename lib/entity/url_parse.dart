import 'package:videoflow/entity/common.dart';
import 'dart:convert';

class LiveDetail {
  String replayUrl;
  String title;
  String liveId;
  String coverUrl;
  int duration;
  int size;
  VideoPlatform platform;
  DownloadFileType fileType;
  LiveDetail({
    this.replayUrl = '',
    this.title = '',
    this.liveId = '',
    this.coverUrl = '',
    this.duration = 0,
    this.size = 0,
    this.platform = VideoPlatform.unknown,
    this.fileType = DownloadFileType.unknown,
  });
  @override
  String toString() => jsonEncode({
    'replayUrl': replayUrl,
    'title': title,
    'liveId': liveId,
    'coverUrl': coverUrl,
    'duration': duration,
    'size': size,
    'platform': platform.name,
    'fileType': fileType.name,
  });
}
