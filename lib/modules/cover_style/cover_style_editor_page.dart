import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/models/db/cover_style.dart';
import 'package:videoflow/modules/cover_style/cover_style_editor_control.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

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
            IconButton(
                onPressed: () {
                  c.editorKey.currentState?.undoAction();
                },
                icon: const Icon(Icons.undo)),
            IconButton(
                onPressed: () {
                  c.editorKey.currentState?.redoAction();
                },
                icon: const Icon(Icons.redo)),
            IconButton(
                onPressed: () {
                  c.editorKey.currentState?.openTextEditor();
                },
                icon: const Icon(Icons.text_fields)),
            IconButton(onPressed: c.save, icon: const Icon(Icons.check)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: _Toolbox(c: c),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _LayerPanel(c: c),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() {
                  final s = c.state.value;
                  return Column(
                    children: [
                      TextFormField(
                        initialValue: s.name,
                        decoration: const InputDecoration(labelText: '样式名称'),
                        onChanged: (v) => c.state.update((st) {
                          if (st != null) st.name = v;
                        }),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: s.backgroundImagePath != null && s.backgroundImagePath!.isNotEmpty
                            ? ProImageEditor.file(
                                File(s.backgroundImagePath!),
                                key: c.editorKey,
                                callbacks: ProImageEditorCallbacks(
                                  onImageEditingComplete: (bytes) async {
                                    c.onImageEditingComplete(bytes);
                                  },
                                  mainEditorCallbacks: MainEditorCallbacks(
                                    onUpdateUI: () {
                                      final newLayers = c.editorKey.currentState?.activeLayers;
                                      if (newLayers != null) {
                                        c.layers.assignAll(newLayers.reversed);
                                      }
                                    },
                                    onSelectedLayerChanged: (id) {
                                      if (id.isEmpty) {
                                        c.selectedLayer.value = null;
                                      } else {
                                        c.selectedLayer.value = c.editorKey.currentState?.activeLayers.firstWhere((element) => element.id == id);
                                      }
                                    },
                                  ),
                                ),
                                configs: const ProImageEditorConfigs(),
                              )
                            : Center(
                                child: OutlinedButton.icon(
                                  onPressed: c.pickBackground,
                                  icon: const Icon(Icons.add_photo_alternate_outlined),
                                  label: const Text('选择背景图'),
                                ),
                              ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: _PropertyPanel(c: c),
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
  final Color value;
  final void Function(Color) onChanged;
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final hex = value.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    final controller = TextEditingController(text: hex);
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        GestureDetector(onTap: () async {
          final initial = value;
          await showDialog(
            context: context,
            builder: (context) {
              Color current = initial;
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  title: const Text('选择颜色'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 200, height: 32, decoration: BoxDecoration(color: current, border: Border.all(color: Colors.grey.shade300))),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('A'),
                        Expanded(
                          child: Slider(
                            value: (((current.toARGB32() >> 24) & 0xFF) / 255.0),
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              setState(() {
                                final argb = current.toARGB32();
                                final r = (argb >> 16) & 0xFF;
                                final g = (argb >> 8) & 0xFF;
                                final b = argb & 0xFF;
                                current = Color.fromARGB((v * 255).round(), r, g, b);
                                onChanged(current);
                              });
                            },
                          ),
                        )
                      ]),
                      Row(children: [
                        const Text('R'),
                        Expanded(
                          child: Slider(
                            value: (((current.toARGB32() >> 16) & 0xFF) / 255.0),
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              setState(() {
                                final argb = current.toARGB32();
                                final a = (argb >> 24) & 0xFF;
                                final g = (argb >> 8) & 0xFF;
                                final b = argb & 0xFF;
                                current = Color.fromARGB(a, (v * 255).round(), g, b);
                                onChanged(current);
                              });
                            },
                          ),
                        )
                      ]),
                      Row(children: [
                        const Text('G'),
                        Expanded(
                          child: Slider(
                            value: (((current.toARGB32() >> 8) & 0xFF) / 255.0),
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              setState(() {
                                final argb = current.toARGB32();
                                final a = (argb >> 24) & 0xFF;
                                final r = (argb >> 16) & 0xFF;
                                final b = argb & 0xFF;
                                current = Color.fromARGB(a, r, (v * 255).round(), b);
                                onChanged(current);
                              });
                            },
                          ),
                        )
                      ]),
                      Row(children: [
                        const Text('B'),
                        Expanded(
                          child: Slider(
                            value: ((current.toARGB32() & 0xFF) / 255.0),
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              setState(() {
                                final argb = current.toARGB32();
                                final a = (argb >> 24) & 0xFF;
                                final r = (argb >> 16) & 0xFF;
                                final g = (argb >> 8) & 0xFF;
                                current = Color.fromARGB(a, r, g, (v * 255).round());
                                onChanged(current);
                              });
                            },
                          ),
                        )
                      ]),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () { onChanged(initial); Navigator.pop(context); }, child: const Text('取消')),
                    TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('确定')),
                  ],
                );
              });
            },
          );
        }, child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: value,
            border: Border.all(color: Colors.grey.shade400),
          ),
        )),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(prefixText: '#'),
            onChanged: (v) {
              String cleaned = v.replaceAll(RegExp(r'^#', caseSensitive: false), '');
              cleaned = cleaned.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
              if (cleaned.length == 6) cleaned = 'FF$cleaned';
              if (cleaned.length == 8) {
                final parsed = int.tryParse(cleaned, radix: 16);
                if (parsed != null) onChanged(Color(parsed));
              }
            },
          ),
        ),
      ],
    );
  }
}

class _Toolbox extends StatelessWidget {
  final CoverStyleEditorControl c;
  const _Toolbox({required this.c});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => c.editorKey.currentState?.openTextEditor(),
          child: const Text('文字'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: c.pickAndAddImage,
          child: const Text('图片'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {},
          child: const Text('背景'),
        ),
        const Divider(height: 24),
        OutlinedButton(onPressed: c.pickBackground, child: const Text('选择底图')),
      ],
    );
  }
}

class _PropertyPanel extends StatelessWidget {
  final CoverStyleEditorControl c;
  const _PropertyPanel({required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layer = c.selectedLayer.value;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('元素属性'),
            const SizedBox(height: 8),
            if (layer is TextLayer)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: layer.text,
                    decoration: const InputDecoration(labelText: '内容'),
                    onChanged: (text) {
                      final newLayer = _copyTextLayer(layer, text: text);
                      final index = c.editorKey.currentState?.getLayerStackIndex(layer);
                      if (index != null && index != -1) {
                        c.editorKey.currentState?.replaceLayer(index: index, layer: newLayer);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _NumberField(
                    label: '字号',
                    value: layer.fontScale,
                    onChanged: (value) {
                      final newLayer = _copyTextLayer(layer, fontScale: value);
                      final index = c.editorKey.currentState?.getLayerStackIndex(layer);
                      if (index != null && index != -1) {
                        c.editorKey.currentState?.replaceLayer(index: index, layer: newLayer);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _ColorField(
                    label: '颜色',
                    value: layer.color,
                    onChanged: (color) {
                      final newLayer = _copyTextLayer(layer, color: color);
                      final index = c.editorKey.currentState?.getLayerStackIndex(layer);
                      if (index != null && index != -1) {
                        c.editorKey.currentState?.replaceLayer(index: index, layer: newLayer);
                      }
                    },
                  ),
                ],
              )
            else if (layer != null)
              Text('Selected: ${layer.runtimeType}')
            else
              const Text('未选择任何元素'),
          ],
        ),
      );
    });
  }
}

class _LayerPanel extends StatelessWidget {
  final CoverStyleEditorControl c;
  const _LayerPanel({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '图层',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: c.layers.length,
              itemBuilder: (context, index) {
                final layer = c.layers[index];
                Widget icon = const Icon(Icons.error);
                String title = '未知图层';
                if (layer is TextLayer) {
                  icon = const Icon(Icons.text_fields);
                  title = layer.text;
                } else if (layer is WidgetLayer) {
                  icon = const Icon(Icons.image);
                  title = '图片';
                }

                return ListTile(
                  key: ValueKey(layer.id),
                  leading: icon,
                  title: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: c.selectedLayer.value?.id == layer.id,
                  onTap: () {
                    c.editorKey.currentState?.selectLayerById(layer.id);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      _isLayerVisible(layer) ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      _toggleLayerVisibility(c, layer);
                    },
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                final editor = c.editorKey.currentState;
                if (editor == null) return;

                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }

                final numLayers = c.layers.length;
                final editorOldIndex = (numLayers - 1) - oldIndex;
                final editorNewIndex = (numLayers - 1) - newIndex;

                editor.moveLayerListPosition(
                  oldIndex: editorOldIndex,
                  newIndex: editorNewIndex,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  bool _isLayerVisible(Layer layer) {
    if (layer is TextLayer) {
      final a = (layer.color.toARGB32() >> 24) & 0xFF;
      return a != 0;
    } else if (layer is WidgetLayer) {
      if (layer.widget is Opacity) {
        return (layer.widget as Opacity).opacity != 0;
      }
    }
    return true;
  }

  void _toggleLayerVisibility(CoverStyleEditorControl c, Layer layer) {
    final editor = c.editorKey.currentState;
    if (editor == null) return;

    Layer newLayer;
    if (layer is TextLayer) {
      final argb = layer.color.toARGB32();
      final a = (argb >> 24) & 0xFF;
      final r = (argb >> 16) & 0xFF;
      final g = (argb >> 8) & 0xFF;
      final b = argb & 0xFF;
      final visible = a != 0;
      final newA = visible ? 0 : 255;
      final bg = layer.background.toARGB32();
      final br = (bg >> 16) & 0xFF;
      final bgc = (bg >> 8) & 0xFF;
      final bb = bg & 0xFF;
      newLayer = _copyTextLayer(
        layer,
        color: Color.fromARGB(newA, r, g, b),
        background: Color.fromARGB(visible ? 0 : 255, br, bgc, bb),
      );
    } else if (layer is WidgetLayer) {
      final isVisible = !(layer.widget is Opacity && (layer.widget as Opacity).opacity == 0);
      Widget newWidget;
      if (isVisible) {
        newWidget = Opacity(opacity: 0, child: layer.widget);
      } else {
        if (layer.widget is Opacity) {
          final child = (layer.widget as Opacity).child;
          newWidget = child ?? const SizedBox.shrink();
        } else {
          newWidget = layer.widget;
        }
      }
      newLayer = layer.copyWith(widget: newWidget);
    } else {
      return;
    }
    final layerIndex = editor.getLayerStackIndex(layer);
    if (layerIndex >= 0) {
      editor.replaceLayer(index: layerIndex, layer: newLayer);
    }
  }
}

TextLayer _copyTextLayer(
  TextLayer oldLayer, {
  String? text,
  Color? color,
  Color? background,
  double? fontScale,
}) {
  return TextLayer(
    id: oldLayer.id,
    key: oldLayer.key,
    text: text ?? oldLayer.text,
    color: color ?? oldLayer.color,
    background: background ?? oldLayer.background,
    fontScale: fontScale ?? oldLayer.fontScale,
    align: oldLayer.align,
    colorMode: oldLayer.colorMode,
    customSecondaryColor: oldLayer.customSecondaryColor,
    flipX: oldLayer.flipX,
    flipY: oldLayer.flipY,
    hit: oldLayer.hit,
    interaction: oldLayer.interaction,
    maxTextWidth: oldLayer.maxTextWidth,
    meta: oldLayer.meta,
    offset: oldLayer.offset,
    rotation: oldLayer.rotation,
    scale: oldLayer.scale,
    textStyle: oldLayer.textStyle,
  );
}
