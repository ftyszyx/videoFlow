// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_task_segment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoTaskSegmentAdapter extends TypeAdapter<VideoTaskSegment> {
  @override
  final int typeId = 6;

  @override
  VideoTaskSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoTaskSegment(
      url: fields[0] as String,
      name: fields[30] as String,
      isOk: fields[60] as bool,
      size: fields[40] as int,
      start: fields[10] as int?,
      end: fields[20] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoTaskSegment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(10)
      ..write(obj.start)
      ..writeByte(20)
      ..write(obj.end)
      ..writeByte(30)
      ..write(obj.name)
      ..writeByte(40)
      ..write(obj.size)
      ..writeByte(60)
      ..write(obj.isOk);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTaskSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
