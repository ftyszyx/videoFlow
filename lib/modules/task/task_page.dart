import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/entity/common.dart';
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
                          controller: controller.nameController,
                          decoration: const InputDecoration(labelText: '任务名称'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      //input task name
                      Expanded(
                        child: TextField(
                          controller: controller.shareLinkController,
                          decoration: const InputDecoration(
                            labelText: '分享链接',
                            hintText: '粘贴分享链接',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = tasks[index];
          final theme = Theme.of(context);
          var statusTitle = '${t.status?.title}' ?? '未开始';
          if (t.errMsg.isNotEmpty) {
            statusTitle = '${t.status?.title}:(${t.errMsg})';
          }
          final statusColor = t.status == null
              ? theme.colorScheme.outline
              : (t.status == TaskStatus.downloadFailed ||
                    t.status == TaskStatus.parseFailed ||
                    t.status == TaskStatus.videoMergeFailed)
              ? theme.colorScheme.error
              : t.status == TaskStatus.pause
              ? theme.colorScheme.tertiary
              : theme.colorScheme.primary;
          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: .1)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // cover thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      image: t.coverPath.isNotEmpty
                          ? DecorationImage(
                              image: t.coverPath.startsWith('http')
                                  ? NetworkImage(t.coverPath)
                                  : (File(t.coverPath).existsSync()
                                        ? FileImage(File(t.coverPath))
                                              as ImageProvider
                                        : AssetImage(t.coverPath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: t.coverPath.isEmpty
                        ? const Icon(Icons.image_outlined, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // main info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusTitle,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (t.subTitle?.isNotEmpty == true ||
                            t.videoTitle?.isNotEmpty == true)
                          Text(
                            [
                              t.videoTitle,
                              t.subTitle,
                            ].where((e) => e?.isNotEmpty == true).join(' · '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.link, size: 14, color: theme.hintColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t.shareLink,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // actions
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Tooltip(
                        message: '开始',
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => controller.startTask(t),
                        ),
                      ),
                      Tooltip(
                        message: '暂停',
                        child: IconButton(
                          icon: const Icon(Icons.pause),
                          onPressed: () => controller.pauseTask(t),
                        ),
                      ),
                      Tooltip(
                        message: '删除',
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.deleteTask(t),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
