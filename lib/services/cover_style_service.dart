import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:videoflow/models/db/cover_style.dart';

class CoverStyleService extends GetxService {
  static CoverStyleService get instance => Get.find<CoverStyleService>();

  late final Box<CoverStyle> _box;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;

  Future<void> init() async {
    _box = await Hive.openBox<CoverStyle>('cover_styles');
  }

  List<CoverStyle> getAll() => _box.values.toList();

  Future<void> put(CoverStyle style) async {
    await _box.put(style.id, style);
    _changed.add(null);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _changed.add(null);
  }
}
