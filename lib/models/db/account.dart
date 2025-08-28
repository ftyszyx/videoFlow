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

  @HiveField(10)
  String? name;

  @HiveField(20)
  Map<String, String>? kuaishouCookie;

  @HiveField(30)
  String? kuaishouUserName;

  @HiveField(40)
  String? kuaishouUserId;

  //expire time
  @HiveField(50)
  int? kuaishouExpireTime;

  @HiveField(60)
  Map<String, String>? xiaoDianCookie;

  @HiveField(70)
  String? xiaoDianUserName;

  @HiveField(80)
  String? xiaoDianUserId;

  @HiveField(90)
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
