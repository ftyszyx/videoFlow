import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/utils/logger.dart';

class HiveDebugPage extends StatefulWidget {
  const HiveDebugPage({super.key});
  @override
  State<HiveDebugPage> createState() => _HiveDebugPageState();
}

class _HiveDebugPageState extends State<HiveDebugPage> {
  final List<String> _boxes = const ['accounts', 'tasks'];
  String _selected = 'accounts';
  List<MapEntry<dynamic, dynamic>> _entries = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openIfNeeded<T>(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<T>(name);
    }
  }

  Future<void> _load() async {
    try {
      List<MapEntry<dynamic, dynamic>> list;
      if (_selected == 'accounts') {
        await _openIfNeeded<Account>('accounts');
        final box = Hive.box<Account>('accounts');
        list = box.keys.map((k) => MapEntry(k, box.get(k))).toList();
      } else {
        await _openIfNeeded<VideoTask>('tasks');
        final box = Hive.box<VideoTask>('tasks');
        list = box.keys.map((k) => MapEntry(k, box.get(k))).toList();
      }
      logger.i('hive debug: $_selected ${list.length}');
      setState(() {
        _entries = list;
      });
    } catch (e, s) {
      setState(() {
        _entries = const [];
      });
      logger.e('hive debug: $_selected error ', error: e, stackTrace: s);
    }
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Account) return v.toJson();
    if (v is VideoTask) return v.toJson();
    if (v is Map) return Map<String, dynamic>.from(v);
    return {'value': v?.toString()};
  }

  Map<String, dynamic> _rowMap(MapEntry<dynamic, dynamic> e) {
    return {'Key': e.key, ..._asMap(e.value)};
  }

  String _pretty(Map<String, dynamic> m) {
    return const JsonEncoder.withIndent('  ').convert(m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive 数据预览'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Box: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selected,
                  items: _boxes
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) async {
                    if (v != null) {
                      setState(() => _selected = v);
                      await _load();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('暂无数据'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final map = _rowMap(_entries[i]);
                      final text = _pretty(map);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withAlpha(60)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text('Key: ${map['Key']}'),
                          subtitle: SelectableText(
                            text,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_all),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: text),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已复制')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
