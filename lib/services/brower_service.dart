import 'dart:io';
import 'package:puppeteer/puppeteer.dart' as puppeteer;
import 'package:web_cloner/services/app_config_service.dart';
import 'package:web_cloner/services/logger.dart';
import 'package:path/path.dart' as path;
import 'package:puppeteer/protocol/network.dart' as puppeteer_network;

class BrowserSession {
  final puppeteer.Browser? browser;
  // final List<PageInfo> pages = [];
  final String? userDataDir;
  bool isClosed = false;
  int maxPage = 10; //最大页面数
  BrowserSession({this.browser, this.userDataDir, this.isClosed = false});

  Future<void> close() async {
    isClosed = true;
    await browser?.close();
    if (userDataDir != null) {
      await Directory(userDataDir!).delete(recursive: true);
    }
  }

  void onConsole(puppeteer.ConsoleMessage msg) {
    // logger.info('[JS_CONSOLE]: ${msg.text}');
  }

  Future<puppeteer.Page> waitForNotBusyPage({
    List<puppeteer_network.Cookie>? cookies,
    Function(puppeteer.Request)? onRequest,
    Function(puppeteer.Response)? onResponse,
  }) async {
    puppeteer.Page? page;
    while (page == null) {
      final pages = await browser!.pages;
      try {
        if (pages.isNotEmpty) {
          page = pages.firstWhere((element) => !element.inUse);
          await _setCookies(page, cookies);
          page.inUse = true;
          page.onConsole.listen(onConsole);
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
          return page;
        } else {
          throw Exception('没有找到可用的页面');
        }
      } catch (e) {
        if (pages.length < maxPage) {
          page = await addpage(
            cookies: cookies,
            onRequest: onRequest,
            onResponse: onResponse,
          );
          page.inUse = true;
          return page;
        }
      }
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    throw Exception('没有找到可用的页面');
  }

  Future<void> _setCookies(
    puppeteer.Page page,
    List<puppeteer_network.Cookie>? cookies,
  ) async {
    if (cookies != null) {
      await page.setCookies(
        cookies
            .map(
              (e) => puppeteer.CookieParam(
                name: e.name,
                value: e.value,
                domain: e.domain,
              ),
            )
            .toList(),
      );
    }
  }

  Future<puppeteer.Page> addpage({
    List<puppeteer_network.Cookie>? cookies,
    Function(puppeteer.Request)? onRequest,
    Function(puppeteer.Response)? onResponse,
  }) async {
    // logger.info('添加页面');
    final page = await browser!.newPage();
    page.onConsole.listen(onConsole);
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
    await page.setUserAgent(AppConfigService.instance.userAgent);
    // await page.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1');
    if (cookies != null) {
      await _setCookies(page, cookies);
    }
    return page;
  }

  Future<puppeteer.Page?> lastPage() async {
    final pages = await browser!.pages;
    if (pages.isNotEmpty) {
      return pages.last;
    } else {
      return null;
      // throw Exception('没有找到可用的页面');
    }
  }
}

class BrowerService {
  static BrowerService? _browerService;
  static BrowerService get instance {
    _browerService ??= BrowerService();
    return _browerService!;
  }

  List<BrowserSession> sessions = [];

  Future<void> init() async {
    sessions = [];
  }

  Future<void> close() async {
    for (var session in sessions) {
      if (session.isClosed) continue;
      await session.close();
    }
    sessions = [];
  }

  Future<BrowserSession> runBrowser({bool forceShowBrowser = false}) async {
    try {
      final String chromiumPath = path.join(
        AppConfigService.instance.chromeDir,
        'chrome.exe',
      );
      if (!await File(chromiumPath).exists()) {
        throw Exception('chrome.exe 未找到，请先完成资源下载，路径: $chromiumPath');
      }
      final args = ['--disable-dev-shm-usage'];
      args.add('--no-sandbox');
      args.add('--disable-setuid-sandbox');
      args.add('--remote-debugging-port=0');
      if (AppConfigService.instance.isdebug) {
        args.add('--auto-open-devtools-for-tabs');
        args.add('--net-log');
        args.add('--unsafely-disable-devtools-self-xss-warnings'); // pasting
      }
      final showBrowser = AppConfigService.instance.isdebug || forceShowBrowser;
      if (!showBrowser) {
        args.add('--headless=new'); // 新 headless，Windows 更稳定
      }
      final userDataDir = path.join(
        AppConfigService.instance.chromeDataPath,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      final browser = await puppeteer.puppeteer.launch(
        executablePath: chromiumPath,
        headless: !showBrowser,
        ignoreHttpsErrors: true,
        args: args,
        userDataDir: userDataDir,
      );
      logger.info('浏览器启动完成: $chromiumPath');
      final browserSession = BrowserSession(
        browser: browser,
        userDataDir: userDataDir,
      );
      sessions.add(browserSession);
      return browserSession;
    } catch (e, s) {
      logger.error('启动浏览器失败', error: e, stackTrace: s);
      throw Exception('启动浏览器失败 ');
    }
  }

  //https://peter.sh/experiments/chromium-command-line-switches/#net-log
  Future<BrowserSession> runBrowserWithPage({
    required String url,
    List<puppeteer_network.Cookie>? cookies,
    bool forceShowBrowser = false,
    bool waitOpen = true,
    Function(puppeteer.Request)? onRequest,
    Function(puppeteer.Response)? onResponse,
  }) async {
    final browserSession = await runBrowser(forceShowBrowser: forceShowBrowser);
    final page = await browserSession.addpage(
      cookies: cookies,
      onRequest: onRequest,
      onResponse: onResponse,
    );
    if (waitOpen) {
      await page.goto(
        url,
        wait: puppeteer.Until.domContentLoaded,
        timeout: const Duration(seconds: 30),
      );
    } else {
      page.goto(
        url,
        wait: puppeteer.Until.domContentLoaded,
        timeout: const Duration(seconds: 30),
      );
    }
    return browserSession;
  }
}
