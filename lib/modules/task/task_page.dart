import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/modules/task/task_control.dart';
import 'package:videoflow/utils/app_style.dart';

class TaskPage extends GetView<TaskControl> {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务')),
      body: Padding(
        padding: AppStyle.edgeInsetsA12,
        child: Column(children: [Expanded(child: _TaskList())]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_task_outlined),
                      const SizedBox(width: 8),
                      Text(
                        '添加任务',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.shareLinkController,
                          decoration: const InputDecoration(
                            labelText: '分享链接',
                            hintText: '粘贴分享链接',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(
                        () => DropdownButton<String>(
                          value:
                              controller.selectedAccountId?.value.isNotEmpty ==
                                  true
                              ? controller.selectedAccountId!.value
                              : null,
                          hint: const Text('选择账号'),
                          items: controller.accounts
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name ?? a.id ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              controller.selectedAccountId?.value = v ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.videoTitleController,
                          decoration: const InputDecoration(labelText: '标题'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller.subTitleController,
                          decoration: const InputDecoration(labelText: '副标题'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Obx(() {
                        final path = controller.coverPath;
                        return Text(
                          path.isEmpty ? '未选择封面' : path,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: controller.pickCover,
                        child: const Text('选择封面'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await controller.addTask();
                            if (context.mounted) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          child: const Text('添加任务'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskList extends GetView<TaskControl> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.tasks;
      if (tasks.isEmpty) {
        return const Center(child: Text('暂无任务'));
      }
      return ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = tasks[index];
          return ListTile(
            title: Text(t.videoTitle.isNotEmpty ? t.videoTitle : t.name),
            subtitle: Text('${t.subTitle}\n状态: ${t.status?.title ?? '未开始'}'),
            isThreeLine: true,
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: '开始',
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => controller.startTask(t),
                ),
                IconButton(
                  tooltip: '暂停',
                  icon: const Icon(Icons.pause),
                  onPressed: () => controller.pauseTask(t),
                ),
                IconButton(
                  tooltip: '删除',
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.deleteTask(t),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
