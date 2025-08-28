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
class VideoTassk {
  VideoTassk({
    required this.id,
    required this.shareLink,
    required this.userId,
    this.name = '',
  });
  //自动生成
  @HiveField(0)
  String id;
  //任务名
  @HiveField(1)
  String name;
  //对应的账号id
  @HiveField(2)
  String userId;

  //视频封面
  @HiveField(3)
  String? coverPath;

  //视频标题
  @HiveField(4)
  String? videoTitle;

  //视频副标题
  @HiveField(5)
  String? subTitle;

  //视频平台
  @HiveField(6)
  VideoPlatform? videoPlatform;

  //下载文件类型
  @HiveField(7)
  DownloadFileType? downloadFileType;

  //下载链接
  @HiveField(8)
  String? downloadUrl;

  //下载路径
  @HiveField(9)
  String? downloadPath;

  //分享链接
  @HiveField(10)
  String shareLink;

  //任务状态
  @HiveField(11)
  TaskStatus? status;

  @HiveField(12)
  int? downloadFileTotalSize;

  @HiveField(14)
  List<VideoTaskSegment>? downloadSegments;

  @HiveField(16)
  String? srcVideoTitle;

  @HiveField(17)
  String? srcVideoId;

  @HiveField(18)
  String? srcVideoCoverUrl;

  @HiveField(19)
  int? srcVideoDuration;

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
}
