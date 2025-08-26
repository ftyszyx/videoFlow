import 'package:hive/hive.dart';
import 'dart:convert';
part 'video_tassk.g.dart';

@HiveType(typeId: 2)
class VideoTassk {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? token;


  toJson()=>{
    'id':id,
    'name':name,
    'token':token,
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 