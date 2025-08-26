import 'dart:convert';

import 'package:hive/hive.dart';
part 'account.g.dart';

@HiveType(typeId: 0)
class Account {
  Account({
    this.id,
    this.name,
    this.kuaishouCookie,
    this.kuaishouUserName,
    this.kuaishouUserId,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  Map<String, String>? kuaishouCookie;

  @HiveField(3)
  String? kuaishouUserName;

  @HiveField(4)
  String? kuaishouUserId;

  //expire time
  @HiveField(5)
  int? kuaishouExpireTime;

  @HiveField(6)
  Map<String, String>? xiaoDianCookie;

  @HiveField(7)
  String? xiaoDianUserName;

  @HiveField(8)
  String? xiaoDianUserId;

  @HiveField(9)
  int? xiaoDianExpireTime;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kuaishouCookie': kuaishouCookie,
    'kuaishouUserName': kuaishouUserName,
    'kuaishouUserId': kuaishouUserId,
    'kuaishouExpireTime': kuaishouExpireTime,
    'xiaoDianCookie': xiaoDianCookie,
    'xiaoDianUserName': xiaoDianUserName,
    'xiaoDianUserId': xiaoDianUserId,
    'xiaoDianExpireTime': xiaoDianExpireTime,
  };
  //tostring
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
