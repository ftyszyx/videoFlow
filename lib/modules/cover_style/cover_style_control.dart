import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/services/cover_style_service.dart';

class CoverStyleControl extends GetxController {
  final RxList<CoverStyle> styles = <CoverStyle>[].obs;

  CoverStyleService get _svc => CoverStyleService.instance;

  @override
  void onInit() {
    super.onInit();
    styles.assignAll(_svc.getAll());
    _svc.changed.listen((_) => styles.assignAll(_svc.getAll()));
  }

  Future<void> create() async {
    final style = CoverStyle(id: const Uuid().v4(), name: '新样式');
    await _svc.put(style);
  }

  Future<void> delete(String id) => _svc.delete(id);
}

// Editor control moved to cover_style_editor_control.dart
