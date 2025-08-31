import 'dart:async';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/models/db/platform_info.dart';

class AccountService extends GetxService {
  static AccountService get instance => Get.find<AccountService>();

  late final Box<Account> _box;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;
  Future<void> init() async {
    _box = await Hive.openBox<Account>('accounts');
  }

  List<Account> getAll() {
    return _box.values.toList();
  }

  Account? getUser(String id) {
    return _box.get(id);
  }

  Future<void> put(Account account) async {
    final String key = account.id?.isNotEmpty == true
        ? account.id!
        : DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(
      key,
      Account(
        id: key,
        name: account.name,
        platformInfos: account.platformInfos,
      ),
    );
    _changed.add(null);
  }

  Future<void> updatePlatformInfo(String id, PlatformInfo platformInfo) async {
    var account = _box.get(id);
    if (account != null) {
      account.platformInfos ??= [];
      final list = account.platformInfos!;
      final idx = list.indexWhere((e) => e.platform == platformInfo.platform);
      if (idx >= 0) {
        list[idx] = platformInfo;
      } else {
        list.add(platformInfo);
      }
      await put(account);
    }
  }

  Future<void> setPlatformInfoExpire(String id, VideoPlatform platform) async {
    var account = _box.get(id);
    if (account != null) {
      account.platformInfos ??= [];
      final list = account.platformInfos!;
      final idx = list.indexWhere((e) => e.platform == platform);
      if (idx >= 0) {
        list[idx].isExpire = true;
        await put(account);
      }
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _changed.add(null);
  }

  void dispose() {
    _changed.close();
  }
}
