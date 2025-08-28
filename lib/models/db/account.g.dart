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
      name: fields[10] as String?,
      kuaishouCookie: (fields[20] as Map?)?.cast<String, String>(),
      kuaishouUserName: fields[30] as String?,
      kuaishouUserId: fields[40] as String?,
    )
      ..kuaishouExpireTime = fields[50] as int?
      ..xiaoDianCookie = (fields[60] as Map?)?.cast<String, String>()
      ..xiaoDianUserName = fields[70] as String?
      ..xiaoDianUserId = fields[80] as String?
      ..xiaoDianExpireTime = fields[90] as int?;
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(20)
      ..write(obj.kuaishouCookie)
      ..writeByte(30)
      ..write(obj.kuaishouUserName)
      ..writeByte(40)
      ..write(obj.kuaishouUserId)
      ..writeByte(50)
      ..write(obj.kuaishouExpireTime)
      ..writeByte(60)
      ..write(obj.xiaoDianCookie)
      ..writeByte(70)
      ..write(obj.xiaoDianUserName)
      ..writeByte(80)
      ..write(obj.xiaoDianUserId)
      ..writeByte(90)
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
