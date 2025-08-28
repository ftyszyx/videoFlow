import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:videoflow/entity/common.dart';
part 'video_task.g.dart';

class VideoTaskSegment {
  String url;
  int? start;
  int? end;
  String name;
  int size;
  bool isOk;
  VideoTaskSegment({
    required this.url,
    required this.name,
    required this.isOk,
    required this.size,
    this.start,
    this.end,
  });
}

@HiveType(typeId: 2)
class VideoTask {
  VideoTask({
    required this.id,
    required this.shareLink,
    required this.userId,
    this.name = '',
  });
  //自动生成
  @HiveField(0)
  String id;
  //任务名
  @HiveField(10)
  String name;
  //对应的账号id
  @HiveField(20)
  String userId;

  //视频封面
  @HiveField(30)
  String? coverPath;

  //视频标题
  @HiveField(40)
  String? videoTitle;

  //视频副标题
  @HiveField(50)
  String? subTitle;

  //视频平台
  @HiveField(60)
  VideoPlatform? videoPlatform;

  //下载文件类型
  @HiveField(70)
  DownloadFileType? downloadFileType;

  //下载链接
  @HiveField(80)
  String? downloadUrl;

  //下载路径
  @HiveField(90)
  String? downloadPath;

  //分享链接
  @HiveField(100)
  String shareLink;

  //任务状态
  @HiveField(110)
  TaskStatus? status;

  @HiveField(120)
  int? downloadFileTotalSize;

  @HiveField(140)
  List<VideoTaskSegment>? downloadSegments;

  @HiveField(160)
  String? srcVideoTitle;

  @HiveField(170)
  String? srcVideoId;

  @HiveField(180)
  String? srcVideoCoverUrl;

  @HiveField(190)
  int? srcVideoDuration;

  @HiveField(200)
  String errMsg = '';

  @HiveField(210)
  String taskLog = '';

  @HiveField(220)
  TaskStatus? pausedFromStatus;

  toJson() => {
    'id': id,
    'name': name,
    'shareLink': shareLink,
    'status': status,
    'videoTitle': videoTitle,
    'videoPlatform': videoPlatform,
    'downloadFileType': downloadFileType,
    'downloadUrl': downloadUrl,
    'downloadPath': downloadPath,
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  bool isPaused() {
    return status == TaskStatus.pause;
  }

  void pause() {
    pausedFromStatus = status;
    status = TaskStatus.pause;
  }

  bool canDownload() {
    if (status == null) {
      return false;
    }
    return status!.code >= TaskStatus.parseCompleted.code;
  }
}
