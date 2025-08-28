import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:videoflow/models/db/video_task.dart';

class TaskService extends GetxService {
  static TaskService get instance => Get.find<TaskService>();

  late final Box<VideoTask> _box;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;
  Future<void> init() async {
    _box = await Hive.openBox<VideoTask>('video_tasks');
  }

  List<VideoTask> getAll() {
    return _box.values.toList();
  }

  Future<void> put(VideoTask task) async {
    await _box.put(task.id, task);
    _changed.add(null);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _changed.add(null);
  }

  Future<void> update(VideoTask task) async {
    await _box.put(task.id, task);
    _changed.add(null);
  }
}
