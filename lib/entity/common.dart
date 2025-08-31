import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

enum DownloadFileType { m3u8, mp4, unknown }




enum VideoPlatform {
  kwai('快手'),
  kwaiShop('快手小店'),
  taobao('淘宝'),
  unknown('未知');

  final String title;
  const VideoPlatform(this.title);
}

enum TaskStatus {
  init('初始化', 0),
  //解析
  waitForParse('等待解析', 11),
  parseing('解析中', 12),
  parseFailed('解析失败', 13),
  parseCompleted('解析完成', 14),
  //下载
  waitForDownload('等待下载', 21),
  downloading('下载中', 22),
  downloadFailed('下载失败', 23),
  downloadMerge('下载合并', 24),
  downloadCompleted('下载完成', 25),
  //视频处理
  videoMerge('视频合并', 31),
  videoMergeFailed('视频合并失败', 32),
  videoMergeCompleted('视频合并完成', 33),
  addCover('添加封面', 34),
  //暂停
  pause('暂停', 41);

  final String title;
  final int code;
  const TaskStatus(this.title, this.code);
}

class BrowserSession {
  final Browser? browser;
  final Page? page;
  final String? userDataDir;
  BrowserSession({this.browser, this.page, this.userDataDir});

  Future<void> close() async {
    await browser?.close();
    if (userDataDir != null) {
      await Directory(userDataDir!).delete(recursive: true);
    }
  }
}


String getPlatformTitle(VideoPlatform platform) {
  switch (platform) {
    case VideoPlatform.kwai:
      return "快手";
    case VideoPlatform.kwaiShop:
      return "快手小店";
    case VideoPlatform.taobao:
      return "淘宝";
    case VideoPlatform.unknown:
      return "未知";
  }
}
