import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/models/db/platform_info.dart';
part 'account.g.dart';



@HiveType(typeId: 0)
class Account {
  Account({
    this.id,
    this.name,
    this.platformInfos,
  });

  @HiveField(0)
  String? id;

  @HiveField(10)
  String? name;

  @HiveField(20)
  List<PlatformInfo>? platformInfos;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platformInfos': platformInfos?.map((e) => e.toJson()).toList(),
  };
  //tostring
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  PlatformInfo? getPlatformInfo(VideoPlatform platform) {
    return platformInfos?.firstWhere((e) => e.platform == platform);
  }
}
