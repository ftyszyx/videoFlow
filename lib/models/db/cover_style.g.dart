// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_style.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoverStyleAdapter extends TypeAdapter<CoverStyle> {
  @override
  final int typeId = 1;

  @override
  CoverStyle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoverStyle(
      id: fields[0] as String,
      name: fields[10] as String,
      backgroundImagePath: fields[20] as String?,
      cropLeft: fields[30] as double?,
      cropTop: fields[31] as double?,
      cropWidth: fields[32] as double?,
      cropHeight: fields[33] as double?,
      titleX: fields[40] as double,
      titleY: fields[41] as double,
      titleFontSize: fields[42] as double,
      titleColor: fields[43] as int,
      titleAlign: fields[44] as int,
      titleFontFamily: fields[45] as String?,
      subX: fields[50] as double,
      subY: fields[51] as double,
      subFontSize: fields[52] as double,
      subColor: fields[53] as int,
      subAlign: fields[54] as int,
      subFontFamily: fields[55] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoverStyle obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(20)
      ..write(obj.backgroundImagePath)
      ..writeByte(30)
      ..write(obj.cropLeft)
      ..writeByte(31)
      ..write(obj.cropTop)
      ..writeByte(32)
      ..write(obj.cropWidth)
      ..writeByte(33)
      ..write(obj.cropHeight)
      ..writeByte(40)
      ..write(obj.titleX)
      ..writeByte(41)
      ..write(obj.titleY)
      ..writeByte(42)
      ..write(obj.titleFontSize)
      ..writeByte(43)
      ..write(obj.titleColor)
      ..writeByte(44)
      ..write(obj.titleAlign)
      ..writeByte(45)
      ..write(obj.titleFontFamily)
      ..writeByte(50)
      ..write(obj.subX)
      ..writeByte(51)
      ..write(obj.subY)
      ..writeByte(52)
      ..write(obj.subFontSize)
      ..writeByte(53)
      ..write(obj.subColor)
      ..writeByte(54)
      ..write(obj.subAlign)
      ..writeByte(55)
      ..write(obj.subFontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
