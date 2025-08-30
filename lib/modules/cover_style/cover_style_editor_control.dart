import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/services/cover_style_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverStyleEditorControl extends GetxController {
  final CoverStyle style;
  CoverStyleEditorControl(this.style);
  final editorKey = GlobalKey<ProImageEditorState>();

  final Rx<CoverStyle> state = Rx<CoverStyle>(CoverStyle(id: '', name: ''));
  final Rx<Layer?> selectedLayer = Rx<Layer?>(null);
  final RxList<Layer> layers = <Layer>[].obs;

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

  Future<void> pickAndAddImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final bytes = await File(path).readAsBytes();
      editorKey.currentState?.addLayer(
        WidgetLayer(
          widget: Image.memory(bytes),
        ),
      );
    }
  }

  Future<void> onImageEditingComplete(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final out = p.join(dir.path, 'cover_${DateTime.now().millisecondsSinceEpoch}.png');
    await File(out).writeAsBytes(bytes);
    state.update((st) {
      if (st != null) st.backgroundImagePath = out;
    });
    save();
  }

  Future<void> save() async {
    final bytes = await editorKey.currentState?.captureEditorImage();
    if (bytes == null) {
      Get.snackbar('错误', '无法生成图片');
      return;
    }

    final dir = await getTemporaryDirectory();
    final out = p.join(dir.path, 'cover_${DateTime.now().millisecondsSinceEpoch}.png');
    await File(out).writeAsBytes(bytes);
    state.update((st) {
      if (st != null) st.backgroundImagePath = out;
    });

    await CoverStyleService.instance.put(state.value);
    Get.snackbar('成功', '封面样式已保存');
  }
}
