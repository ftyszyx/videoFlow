import 'dart:async';
import 'package:get/get.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/services/account_service.dart';

class AccountControl extends GetxController {
  final RxList<Account> accounts = <Account>[].obs;
  late final AccountService _service;
  StreamSubscription? _sub;
  void _reload() {
    accounts.value = _service.getAll();
  }

  @override
  void onInit() {
    super.onInit();
    _service = AccountService.instance;
    _reload();
    _sub = _service.changed.listen((_) {
      _reload();
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> addOrUpdate(Account account) async {
    await _service.put(account);
  }

  Future<void> deleteById(String id) async {
    await _service.delete(id);
  }
}
