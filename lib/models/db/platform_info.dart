import 'package:hive/hive.dart';
import 'package:videoflow/entity/common.dart';
import 'dart:convert';

part 'platform_info.g.dart';


@HiveType(typeId: 2)
class PlatformInfo {
  @HiveField(0)
  String? userId;
  @HiveField(10)
  String? userName;
  @HiveField(20)
  VideoPlatform platform;
  @HiveField(30)
  String? headUrl;
  @HiveField(40)
  Map<String, String>? cookie;

  PlatformInfo({
    this.userId,
    this.userName,
    required this.platform,
    this.headUrl,
    this.cookie,
  });

  toJson() => {
    'userId': userId,
    'userName': userName,
    'platform': platform.name,
    'headUrl': headUrl,
    'cookie': cookie,
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}