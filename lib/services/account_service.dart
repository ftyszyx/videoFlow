import 'dart:async';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/utils/logger.dart';

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

  Future<void> put(Account account) async {
    final String key = account.id?.isNotEmpty == true
        ? account.id!
        : DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(
      key,
      Account(
        id: key,
        name: account.name,
        kuaishouCookie: account.kuaishouCookie,
        kuaishouUserName: account.kuaishouUserName,
        kuaishouUserId: account.kuaishouUserId,
      ),
    );
    _changed.add(null);
  }

  Future<void> updateKuaishouCookie(String id, Map<String, String> cookie) async {
    //            //; Expires=Mon, 15 Sep 2025 14:19:47 GMT
    var account = _box.get(id);
    if (account != null) {
      account.kuaishouCookie = cookie;
      var expireTime=cookie["Expires"];
      if(expireTime!=null){
        account.kuaishouExpireTime=DateTime.parse(expireTime).millisecondsSinceEpoch;
      }
      logger.i("updateKuaishouCookie: ${account.toString()}");
      await put(account);
    }
  }

  Future<void> updateXiaoDianCookie(String id, Map<String, String> cookie) async {
    var account = _box.get(id);
    if (account != null) {
      account.xiaoDianCookie = cookie;
      await put(account);
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
