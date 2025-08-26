import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:videoflow/models/db/video_tassk.dart';

class TaskService extends GetxService {
  static TaskService get instance => Get.find<TaskService>();

  late final Box<VideoTassk> _box;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;
  Future<void> init() async {
    _box = await Hive.openBox<VideoTassk>('video_tasks');
  }

  List<VideoTassk> getAll() {
    return _box.values.toList();
  }

  Future<void> put(VideoTassk task) async {
    await _box.put(task.id, task);
    _changed.add(null);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _changed.add(null);
  }

  Future<void> update(VideoTassk task) async {
    await _box.put(task.id, task);
    _changed.add(null);
  }
}
