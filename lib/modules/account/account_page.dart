import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/models/db/platform_info.dart';
import 'package:videoflow/modules/account/account_control.dart';
import 'package:videoflow/utils/route_path.dart';

class AccountPage extends GetView<AccountControl> {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账号管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final items = controller.accounts;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 56,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(height: 8),
                Text(
                  '暂无账号',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    _showEditSheet(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加账号'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemBuilder: (_, i) {
            final a = items[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  child: Text(
                    (a.name ?? '?').characters.isNotEmpty
                        ? a.name!.characters.first
                        : '?',
                  ),
                ),
                title: Text(a.name ?? ''),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ...[
                      for (final pi in (a.platformInfos ?? <PlatformInfo>[]))
                        ...[
                          Row(
                            children: [
                              Text('${getPlatformTitle(pi.platform)}: '),
                              Builder(builder: (_) { final st = _computeStatus(pi); return Text(st.label, style: TextStyle(color: st.color, fontWeight: FontWeight.w600)); }),
                              const SizedBox(width: 8),
                              Text('uid: ${pi.userId}'),
                              const SizedBox(width: 8),
                              Expanded(child: Text('用户名: ${pi.userName}', overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],
                    ],
                  ],
                ),
                trailing: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (a.id != null) {
                          Get.toNamed(
                            RoutePath.kwaiQrLogin,
                            parameters: {'id': a.id!},
                          );
                        }
                      },
                      child: const Text('登录快手'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (a.id != null) {
                          Get.toNamed(
                            RoutePath.shopQrLogin,
                            parameters: {'id': a.id!},
                          );
                        }
                      },
                      child: const Text('登录小店'),
                    ),
                    IconButton(
                      tooltip: '编辑',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showEditSheet(context, account: a);
                      },
                    ),
                    IconButton(
                      tooltip: '删除',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        if (a.id != null) {
                          controller.deleteById(a.id!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: items.length,
        );
      }),
    );
  }

  _KsStatus _computeStatus(PlatformInfo? platformInfo) {
    var cookie = platformInfo?.cookie;
    if (cookie == null || cookie.isEmpty) return _KsStatus('未登录', Colors.grey);
    return _KsStatus('已登录', Colors.green);
  }

  void _showEditSheet(BuildContext context, {Account? account}) {
    final TextEditingController nameCtrl = TextEditingController(
      text: account?.name ?? '',
    );
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
                      Icon(account == null ? Icons.person_add_alt : Icons.edit),
                      const SizedBox(width: 8),
                      Text(
                        account == null ? '添加账号' : '编辑账号',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
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
                            await controller.addOrUpdate(
                              Account(
                                id: account?.id,
                                name: nameCtrl.text.trim(),
                              ),
                            );
                            if (context.mounted) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          child: const Text('保存'),
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

class _KsStatus {
  final String label;
  final Color color;
  const _KsStatus(this.label, this.color);
}
