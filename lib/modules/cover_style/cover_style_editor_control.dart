import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/services/cover_style_service.dart';

class CoverStyleEditorControl extends GetxController {
  final CoverStyle style;
  CoverStyleEditorControl(this.style);

  final Rx<CoverStyle> state = Rx<CoverStyle>(CoverStyle(id: '', name: ''));
  final RxDouble imageScale = 1.0.obs;
  final RxString selected = 'title'.obs; // 'title' or 'sub'
  final RxDouble titleRotationRad = 0.0.obs;
  final RxDouble subRotationRad = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    state.value = style;
  }

  Future<void> pickBackground() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      state.update((s) {
        if (s != null) s.backgroundImagePath = result.files.single.path!;
      });
    }
  }

  Future<void> save() async {
    await CoverStyleService.instance.put(state.value);
  }
}
