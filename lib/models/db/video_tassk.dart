import 'package:hive/hive.dart';
part 'video_tassk.g.dart';

@HiveType(typeId: 2)
class VideoTassk {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? token;
} 