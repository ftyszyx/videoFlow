// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoTasskAdapter extends TypeAdapter<VideoTassk> {
  @override
  final int typeId = 2;

  @override
  VideoTassk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoTassk(
      id: fields[0] as String,
      shareLink: fields[10] as String,
      userId: fields[2] as String,
      name: fields[1] as String,
    )
      ..coverPath = fields[3] as String?
      ..videoTitle = fields[4] as String?
      ..subTitle = fields[5] as String?
      ..videoPlatform = fields[6] as VideoPlatform?
      ..downloadFileType = fields[7] as DownloadFileType?
      ..downloadUrl = fields[8] as String?
      ..downloadPath = fields[9] as String?
      ..status = fields[11] as TaskStatus?
      ..downloadFileTotalSize = fields[12] as int?
      ..downloadSegments = (fields[14] as List?)?.cast<VideoTaskSegment>();
  }

  @override
  void write(BinaryWriter writer, VideoTassk obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.coverPath)
      ..writeByte(4)
      ..write(obj.videoTitle)
      ..writeByte(5)
      ..write(obj.subTitle)
      ..writeByte(6)
      ..write(obj.videoPlatform)
      ..writeByte(7)
      ..write(obj.downloadFileType)
      ..writeByte(8)
      ..write(obj.downloadUrl)
      ..writeByte(9)
      ..write(obj.downloadPath)
      ..writeByte(10)
      ..write(obj.shareLink)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.downloadFileTotalSize)
      ..writeByte(14)
      ..write(obj.downloadSegments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTasskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
