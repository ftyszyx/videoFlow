// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoTaskAdapter extends TypeAdapter<VideoTask> {
  @override
  final int typeId = 4;

  @override
  VideoTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoTask(
      id: fields[0] as String,
      shareLink: fields[100] as String,
      userId: fields[20] as String,
      coverPath: fields[30] as String,
      subTitle: fields[50] as String?,
      name: fields[10] as String,
    )
      ..videoTitle = fields[40] as String?
      ..videoPlatform = fields[60] as VideoPlatform?
      ..downloadFileType = fields[70] as DownloadFileType?
      ..downloadUrl = fields[80] as String?
      ..downloadPath = fields[90] as String?
      ..status = fields[110] as TaskStatus?
      ..downloadFileTotalSize = fields[120] as int?
      ..downloadSegments = (fields[140] as List?)?.cast<VideoTaskSegment>()
      ..srcVideoTitle = fields[160] as String?
      ..srcVideoId = fields[170] as String?
      ..srcVideoCoverUrl = fields[180] as String?
      ..srcVideoDuration = fields[190] as int?
      ..errMsg = fields[200] as String
      ..taskLog = fields[210] as String
      ..pausedFromStatus = fields[220] as TaskStatus?
      ..coverStyleId = fields[230] as String?;
  }

  @override
  void write(BinaryWriter writer, VideoTask obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(20)
      ..write(obj.userId)
      ..writeByte(30)
      ..write(obj.coverPath)
      ..writeByte(40)
      ..write(obj.videoTitle)
      ..writeByte(50)
      ..write(obj.subTitle)
      ..writeByte(60)
      ..write(obj.videoPlatform)
      ..writeByte(70)
      ..write(obj.downloadFileType)
      ..writeByte(80)
      ..write(obj.downloadUrl)
      ..writeByte(90)
      ..write(obj.downloadPath)
      ..writeByte(100)
      ..write(obj.shareLink)
      ..writeByte(110)
      ..write(obj.status)
      ..writeByte(120)
      ..write(obj.downloadFileTotalSize)
      ..writeByte(140)
      ..write(obj.downloadSegments)
      ..writeByte(160)
      ..write(obj.srcVideoTitle)
      ..writeByte(170)
      ..write(obj.srcVideoId)
      ..writeByte(180)
      ..write(obj.srcVideoCoverUrl)
      ..writeByte(190)
      ..write(obj.srcVideoDuration)
      ..writeByte(200)
      ..write(obj.errMsg)
      ..writeByte(210)
      ..write(obj.taskLog)
      ..writeByte(220)
      ..write(obj.pausedFromStatus)
      ..writeByte(230)
      ..write(obj.coverStyleId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
