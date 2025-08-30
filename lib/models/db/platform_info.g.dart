// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlatformInfoAdapter extends TypeAdapter<PlatformInfo> {
  @override
  final int typeId = 2;

  @override
  PlatformInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlatformInfo(
      userId: fields[0] as String?,
      userName: fields[10] as String?,
      platform: fields[20] as VideoPlatform,
      headUrl: fields[30] as String?,
      cookie: (fields[40] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlatformInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.userName)
      ..writeByte(20)
      ..write(obj.platform)
      ..writeByte(30)
      ..write(obj.headUrl)
      ..writeByte(40)
      ..write(obj.cookie);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
