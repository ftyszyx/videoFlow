import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/modules/cover_style/cover_style_editor_control.dart';
import 'package:videoflow/widgets/pro_image_editor/pro_image_editor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverStyleEditorPage extends GetView<CoverStyleEditorControl> {
  final CoverStyle style;
  const CoverStyleEditorPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoverStyleEditorControl>(
      init: CoverStyleEditorControl(style),
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text('编辑样式'),
          actions: [
            IconButton(onPressed: c.save, icon: const Icon(Icons.check)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final s = c.state.value;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final scale = c.imageScale.value;
                        return Stack(
                          children: [
                            if (s.backgroundImagePath != null)
                              Transform.scale(
                                scale: scale,
                                alignment: Alignment.topLeft,
                                child: Image.file(
                                  File(s.backgroundImagePath!),
                                  fit: BoxFit.contain,
                                  width: constraints.maxWidth,
                                ),
                              )
                            else
                              Container(color: Colors.grey.shade100),
                            Positioned(
                              left: s.titleX,
                              top: s.titleY,
                              child: GestureDetector(
                                onPanUpdate: (d) => c.state.update((st) {
                                  if (st != null) {
                                    st.titleX = (st.titleX + d.delta.dx).clamp(
                                      0,
                                      constraints.maxWidth,
                                    );
                                    st.titleY = (st.titleY + d.delta.dy).clamp(
                                      0,
                                      constraints.maxHeight,
                                    );
                                  }
                                }),
                                child: Text(
                                  '标题示例',
                                  style: TextStyle(
                                    color: Color(s.titleColor),
                                    fontSize: s.titleFontSize,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: s.subX,
                              top: s.subY,
                              child: GestureDetector(
                                onPanUpdate: (d) => c.state.update((st) {
                                  if (st != null) {
                                    st.subX = (st.subX + d.delta.dx).clamp(
                                      0,
                                      constraints.maxWidth,
                                    );
                                    st.subY = (st.subY + d.delta.dy).clamp(
                                      0,
                                      constraints.maxHeight,
                                    );
                                  }
                                }),
                                child: Text(
                                  '副标题示例',
                                  style: TextStyle(
                                    color: Color(s.subColor),
                                    fontSize: s.subFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: c.state.value.name,
                      decoration: const InputDecoration(labelText: '样式名称'),
                      onChanged: (v) => c.state.update((s) {
                        if (s != null) s.name = v;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: c.pickBackground,
                    child: const Text('选择底图'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final s = c.state.value;
                      if (s.backgroundImagePath == null) {
                        Get.snackbar('提示', '请先选择底图');
                        return;
                      }
                      final Uint8List bytes = await File(
                        s.backgroundImagePath!,
                      ).readAsBytes();
                      final Uint8List? edited = await Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => ProImageEditor.memory(
                                bytes,
                                callbacks: ProImageEditorCallbacks(
                                  onImageEditingComplete:
                                      (Uint8List outBytes) async {
                                        Navigator.pop(context, outBytes);
                                      },
                                ),
                              ),
                            ),
                          );
                      if (edited == null) return;
                      final dir = await getTemporaryDirectory();
                      final out = p.join(
                        dir.path,
                        'cover_${DateTime.now().millisecondsSinceEpoch}.png',
                      );
                      await File(out).writeAsBytes(edited);
                      c.state.update((st) {
                        if (st != null) st.backgroundImagePath = out;
                      });
                      await c.save();
                    },
                    child: const Text('打开高级编辑器'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _NumberField(
                label: '标题字号',
                value: c.state.value.titleFontSize,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.titleFontSize = v;
                }),
              ),
              _NumberField(
                label: '副标题字号',
                value: c.state.value.subFontSize,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.subFontSize = v;
                }),
              ),
              _ColorField(
                label: '标题颜色 (ARGB hex)',
                value: c.state.value.titleColor,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.titleColor = v;
                }),
              ),
              _ColorField(
                label: '副标题颜色 (ARGB hex)',
                value: c.state.value.subColor,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.subColor = v;
                }),
              ),
              Row(
                children: [
                  const Text('底图缩放'),
                  Expanded(
                    child: Obx(
                      () => Slider(
                        value: c.imageScale.value,
                        min: 0.25,
                        max: 2.0,
                        divisions: 7,
                        label: c.imageScale.value.toStringAsFixed(2),
                        onChanged: (v) => c.imageScale.value = v,
                      ),
                    ),
                  ),
                ],
              ),
              _NumberField(
                label: '标题X',
                value: c.state.value.titleX,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.titleX = v;
                }),
              ),
              _NumberField(
                label: '标题Y',
                value: c.state.value.titleY,
                onChanged: (v) => c.state.update((s) {
                  if (s != null) s.titleY = v;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final double value;
  final void Function(double) onChanged;
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) => onChanged(double.tryParse(v) ?? value),
          ),
        ),
      ],
    );
  }
}

class _ColorField extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int) onChanged;
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    final controller = TextEditingController(text: hex);
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(value),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(prefixText: '0x'),
            onChanged: (v) {
              final cleaned = v.replaceAll(
                RegExp(r'^0x', caseSensitive: false),
                '',
              );
              final parsed = int.tryParse(cleaned, radix: 16);
              if (parsed != null) onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}
