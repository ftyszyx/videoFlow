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
      cookies: (fields[40] as List?)?.cast<Cookie>(),
    )..isExpire = fields[50] as bool?;
  }

  @override
  void write(BinaryWriter writer, PlatformInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.userName)
      ..writeByte(20)
      ..write(obj.platform)
      ..writeByte(30)
      ..write(obj.headUrl)
      ..writeByte(40)
      ..write(obj.cookies)
      ..writeByte(50)
      ..write(obj.isExpire);
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
