// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_tassk.dart';

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
    return VideoTassk()
      ..id = fields[0] as String?
      ..name = fields[1] as String?
      ..token = fields[2] as String?;
  }

  @override
  void write(BinaryWriter writer, VideoTassk obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.token);
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
