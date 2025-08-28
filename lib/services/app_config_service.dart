import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class AppConfigService extends GetxService {
  LogLevel _logLevel = LogLevel.info;
  LogLevel get logLevel => _logLevel;

  late String _appDataPath;
  String get appDataPath => _appDataPath;

  late String _appCachePath;
  String get appCachePath => _appCachePath;

  late String _appConfigPath;
  String get appConfigPath => _appConfigPath;

  bool _isdebug = false;
  bool get isdebug => _isdebug;

  Map<String, dynamic> _config = {};
  Map<String, dynamic> get config => _config;

  static AppConfigService get instance => Get.find<AppConfigService>();
  Future init() async {
    _appDataPath = (await getApplicationSupportDirectory()).path;
    _appCachePath = (await getApplicationCacheDirectory()).path;
    var appConfigPath = path.join(_appDataPath, 'config.json');
    _appConfigPath = appConfigPath;
    _isdebug = false;
    if (File(appConfigPath).existsSync()) {
      _config = json.decode(File(appConfigPath).readAsStringSync());
      _logLevel = LogLevel.values.firstWhere(
        (e) => e.name == _config['logLevel'],
        orElse: () => LogLevel.info,
      );
      _isdebug = _config['isdebug'] ?? false;
    } else {
      _config = {'logLevel': _logLevel.name, 'isdebug': _isdebug};
      File(appConfigPath).createSync(recursive: true);
      File(appConfigPath).writeAsStringSync(json.encode(_config));
    }
  }

  void setLogLevel(LogLevel level) {
    setValue('logLevel', level.name);
  }

  LogLevel getLogLevel() {
    return LogLevel.values.firstWhere(
      (e) => e.name == getValue('logLevel', _logLevel.name),
      orElse: () => _logLevel,
    );
  }

  T getValue<T>(dynamic key, T defaultValue) {
    return _config[key] ?? defaultValue;
  }

  void setValue(dynamic key, dynamic value) {
    _config[key] = value;
    File(appConfigPath).writeAsStringSync(json.encode(_config));
  }

  Future removeValue(dynamic key) async {
    _config.remove(key);
    File(appConfigPath).writeAsStringSync(json.encode(_config));
  }
}
