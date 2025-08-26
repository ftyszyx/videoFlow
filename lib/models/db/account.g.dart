// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      id: fields[0] as String?,
      name: fields[1] as String?,
      kuaishouCookie: (fields[2] as Map?)?.cast<String, String>(),
      kuaishouUserName: fields[3] as String?,
      kuaishouUserId: fields[4] as String?,
    )
      ..kuaishouExpireTime = fields[5] as int?
      ..xiaoDianCookie = (fields[6] as Map?)?.cast<String, String>()
      ..xiaoDianUserName = fields[7] as String?
      ..xiaoDianUserId = fields[8] as String?
      ..xiaoDianExpireTime = fields[9] as int?;
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.kuaishouCookie)
      ..writeByte(3)
      ..write(obj.kuaishouUserName)
      ..writeByte(4)
      ..write(obj.kuaishouUserId)
      ..writeByte(5)
      ..write(obj.kuaishouExpireTime)
      ..writeByte(6)
      ..write(obj.xiaoDianCookie)
      ..writeByte(7)
      ..write(obj.xiaoDianUserName)
      ..writeByte(8)
      ..write(obj.xiaoDianUserId)
      ..writeByte(9)
      ..write(obj.xiaoDianExpireTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
