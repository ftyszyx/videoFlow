
import 'package:hive/hive.dart';
import 'dart:convert';
part 'video_task_segment.g.dart';

@HiveType(typeId: 6)
class VideoTaskSegment {
  @HiveField(0)
  String url;
  @HiveField(10)
  int? start;
  @HiveField(20)
  int? end;
  @HiveField(30)
  String name;
  @HiveField(40)
  int size;
  @HiveField(60)
   bool isOk;
  @HiveField(70)
  VideoTaskSegment({
    required this.url,
    required this.name,
    required this.isOk,
    required this.size,
    this.start,
    this.end,
  });
  toJson() => {
    'url': url,
    'start': start,
    'end': end,
    'name': name,
    'size': size,
    'isOk': isOk,
  };  
  @override
    String toString() {
    return jsonEncode(toJson());
  }
}