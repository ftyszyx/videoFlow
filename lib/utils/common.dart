import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class CommonUtils {
  static late PackageInfo packageInfo;

  static Map<String, String> cookieAdd(
    Map<String, String> cookie,
    String value,
  ) {
    var cookieArr = value.split(";");
    for (var cookieItem in cookieArr) {
      if (cookieItem.isNotEmpty) {
        var keyvalue = cookieItem.split("=");
        if (keyvalue.length == 2) {
          cookie[keyvalue[0]] = keyvalue[1];
        }
      }
    }
    return cookie;
  }

  static String formatSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    }
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
    return '${(sizeInBytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static String formatDuration(int durationInSeconds) {
    if (durationInSeconds < 60) {
      return '$durationInSeconds 秒';
    }
    if (durationInSeconds < 60 * 60) {
      return '${(durationInSeconds / 60).toStringAsFixed(2)} 分';
    }
    return '${(durationInSeconds / 60 / 60).toStringAsFixed(2)} 小时';
  }

  static String formatDownloadSpeed(int speedBytesPerSecond) {
    if (speedBytesPerSecond < 1024) {
      return '${speedBytesPerSecond}B/s';
    }
    if (speedBytesPerSecond < 1024 * 1024) {
      return '${(speedBytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    }
    if (speedBytesPerSecond < 1024 * 1024 * 1024) {
      return '${(speedBytesPerSecond / 1024 / 1024).toStringAsFixed(2)} MB/s';
    }
    return '${(speedBytesPerSecond / 1024 / 1024 / 1024).toStringAsFixed(2)} GB/s';
  }

  static void openPath(String path) {
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [path]);
    }
  }

  /*
//https://peter.sh/experiments/chromium-command-line-switches/#net-log
  static Future<(Browser, Page,bool)> runBrowser({required String url, required String keyname,bool forceShowBrowser=false, Function(Request)? onRequest, Function(Response)? onResponse}) async {
    try {
      final String exeDir = path.dirname(Platform.resolvedExecutable);
      final String chromiumPath = path.join(exeDir, 'data', 'flutter_assets', 'assets', 'chrome-win', 'chrome.exe');
      if (!await File(chromiumPath).exists()) {
        throw DownloadError('打包的 chrome.exe 未找到，路径: $chromiumPath');
      }
      logger.i('chromiumPath: $chromiumPath');
      var args = ['--disable-dev-shm-usage'];
      args.add('--no-sandbox');
      args.add('--disable-setuid-sandbox');
      if(LocalSetting.instance.isdebug){
        args.add('--auto-open-devtools-for-tabs');
        args.add('--net-log');
        args.add('--unsafely-disable-devtools-self-xss-warnings');// pasting 
      }
      final cookies = await AppCookie.getCookies(keyname);
      //options.AddUserProfilePreference("console.log.preserveLog", true);
      final showBrowser = LocalSetting.instance.isdebug||forceShowBrowser;
      var browser = await puppeteer.launch(
        executablePath: chromiumPath,
        headless: !showBrowser,
        ignoreHttpsErrors: true,
        args: args,
      );
      final page = await browser.newPage();
      page.onConsole.listen((event) {
        logger.d('browser_log: ${event.text}');
      });
      page.onRequest.listen((request) {
        if (onRequest != null) {
          onRequest(request);
        }
      });
      page.onResponse.listen((response) {
        if (onResponse != null) {
          onResponse(response);
        }
      });
      await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36');
      // await page.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1');
      await page.setCookies(cookies);
      logger.i('浏览器正在导航到: $url');
      await page.goto(url, wait: Until.networkIdle,timeout: const Duration(seconds: 0));
      //set cookies
      return (browser, page,showBrowser);
    } catch (e) {
      logger.e('启动浏览器失败', error: e);
      throw DownloadError('启动浏览器失败');
    }
  }

  static Future<void> playMp4(String videoPath) async {
    final exeDir = path.dirname(Platform.resolvedExecutable);
    final ffplayPath = path.join(exeDir, 'data', 'flutter_assets', 'assets', 'ffmpeg', 'ffplay.exe');
    if (!await File(ffplayPath).exists()) {
      throw DownloadError('打包的 ffplay.exe 未找到，路径: $ffplayPath');
    }
    final result = await Process.run(ffplayPath, [videoPath]);
    if (result.exitCode == 0) {
      return;
    }
    throw DownloadError('播放失败');
  }

  static String getFileName(String path) {
    if (Platform.isWindows) {
      return path.split('\\').last.split('.').first;
    }
    return path.split('/').last.split('.').first;
  }

  static String getFileExtension(String path) {
    if (Platform.isWindows) {
      return path.split('\\').last.split('.').last;
    }
    return path.split('/').last.split('.').last;
  }
  */
}
