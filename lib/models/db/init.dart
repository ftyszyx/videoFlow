import 'package:hive/hive.dart';
import 'package:web_cloner/models/account.dart';
import 'package:web_cloner/models/task.dart';
import 'package:web_cloner/models/other_adapter.dart';

class ModelManager {
  static Future<void> init() async {
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(CookieAdapter());
  }
}
