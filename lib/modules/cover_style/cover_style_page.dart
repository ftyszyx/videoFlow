import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/modules/cover_style/cover_style_control.dart';
import 'package:videoflow/modules/cover_style/cover_style_card.dart';
import 'package:videoflow/modules/cover_style/cover_style_editor_page.dart';

class CoverStylePage extends GetView<CoverStyleControl> {
  const CoverStylePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('封面样式')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.create,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final items = controller.styles;
        if (items.isEmpty) {
          return const Center(child: Text('暂无样式'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 16 / 10,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => CoverStyleCard(
            style: items[i],
            onDelete: () => controller.delete(items[i].id),
            onTap: () => Get.to(() => CoverStyleEditorPage(style: items[i])),
          ),
        );
      }),
    );
  }
}
