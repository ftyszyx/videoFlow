import 'dart:convert';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/services/task_servcie.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:videoflow/entity/url_parse.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/models/db/video_task.dart';

class KuaishouParser {
  static Future<void> parse(VideoTask task) async {
    task.downloadUrl = null;
    final shortUrl = _extractShortUrl(task.shareLink);
    if (shortUrl == null) {
      TaskService.instance.updateStatus(
        id: task.id,
        status: TaskStatus.parseFailed,
        errMsg: '在分享文本中找不到有效的快手短链接',
      );
      return;
    }
    logger.i('提取到短链接: $shortUrl');
    await _getRedirectUrl(task: task, shortUrl: shortUrl);
    if (task.status == TaskStatus.parseFailed || task.isPaused()) {
      return;
    }
    task.videoPlatform = VideoPlatform.kwai;
    task.downloadFileType = DownloadFileType.mp4;
    if (task.downloadUrl != null) {
      final uri = Uri.parse(task.downloadUrl!);
      task.downloadUrl = '${uri.scheme}://${uri.host}${uri.path}';
    }
    if (task.srcVideoCoverUrl != null) {
      final uri = Uri.parse(task.srcVideoCoverUrl!);
      task.srcVideoCoverUrl = '${uri.scheme}://${uri.host}${uri.path}';
    }
    task.status = TaskStatus.parseCompleted;
    return;
  }

  static String? _extractShortUrl(String text) {
    final regex = RegExp(r'https?://v\.kuaishou\.com/([a-zA-Z0-9]+)');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  static Future<void> _getRedirectUrl({
    required VideoTask task,
    required String shortUrl,
  }) async {
    BrowserSession? browserSession;
    Map<String, LiveDetail> responseLiveDetails = {};
    LiveDetail? getLiveDetail;
    try {
      logger.i('正在启动本地浏览器以解析链接 ...');
      var userinfo = AccountService.instance.getUser(task.userId);
      if (userinfo == null) {
        TaskService.instance.updateStatus(
          id: task.id,
          status: TaskStatus.parseFailed,
          errMsg: '用户信息未找到',
        );
        return;
      }
      var platinfo = userinfo.getPlatformInfo(VideoPlatform.kwai);
      if (platinfo == null) {
        TaskService.instance.updateStatus(
          id: task.id,
          status: TaskStatus.parseFailed,
          errMsg: '用户快手没有登录',
        );
        return;
      }
      var kuaishouCookies = platinfo.cookies;
      if (kuaishouCookies == null) {
        TaskService.instance.updateStatus(
          id: task.id,
          status: TaskStatus.parseFailed,
          errMsg: '用户快手cookie未找到',
        );
        return;
      }
      browserSession = await CommonUtils.runBrowser(
        url: shortUrl,
        cookies: kuaishouCookies,
        forceShowBrowser: true,
        onRequest: (request) {
          if (request.url.contains('.mp4')) {
            final videoUrl = Uri.parse(request.url);
            final videoUrlId = videoUrl.queryParameters['clientCacheKey'] ?? '';
            if (task.srcVideoId != null &&
                videoUrlId.startsWith(task.srcVideoId!)) {
              logger.i('捕获到视频流链接 from request: ${request.url}');
              return;
            }
          }
        },
        onResponse: (response) async {
          if (response.request.url.startsWith(
            "https://v.m.chenzhongtech.com/rest/wd/ugH5App/recommend/photos",
          )) {
            final data = jsonDecode(await response.text);
            final feedinfo = data['data']['finishPlayingRecommend']['feeds'][0];
            final responseVideoId = feedinfo['photoId'];
            if (responseLiveDetails.containsKey(responseVideoId)) {
              return;
            } else {
              var liveDetail = LiveDetail();
              liveDetail.liveId = responseVideoId;
              liveDetail.replayUrl = feedinfo['mainMvUrls'][0]['url'];
              liveDetail.coverUrl = feedinfo['coverUrls'][0]['url'];
              liveDetail.title = feedinfo['caption'];
              liveDetail.duration = feedinfo['duration'] ~/ 1000;
              responseLiveDetails[responseVideoId] = liveDetail;
              logger.i('捕获到视频流链接  from response: $liveDetail ');
            }
          }
        },
      );
      if (task.isPaused()) {
        return;
      }
      final page = browserSession.page!;
      final finalUrl = page.url!;
      logger.i('redirect url: $finalUrl');
      final uri = Uri.parse(finalUrl);
      String? photoId = uri.queryParameters['photoId'];
      if (photoId == null) {
        task.errMsg = '在分享文本中找不到有效的快手短链接';
        task.status = TaskStatus.parseFailed;
        return;
      }
      final videoid = photoId;
      logger.i('视频id: $videoid');
      task.srcVideoId = videoid;
      if (responseLiveDetails.containsKey(videoid)) {
        getLiveDetail = responseLiveDetails[videoid]!;
        logger.i('使用responseLiveDetails中的数据: ${task.srcVideoTitle}');
        return;
      }
      try {
        logger.i('get buttonElement');
        var buttonElement = await page.$('button.pl-btn');
        logger.i('buttonElement: $buttonElement');
        final buttonText = await page.evaluate(
          'document.querySelector("button.pl-btn").innerText',
        );
        if (buttonText == '马上登录') {
          logger.i('clear cookies');
          await AccountService.instance.setPlatformInfoExpire(
            task.userId,
            VideoPlatform.kwai,
          );
          TaskService.instance.updateStatus(
            id: task.id,
            status: TaskStatus.parseFailed,
            errMsg: '用户未登录',
          );
          return;
        }
      } catch (e) {
        logger.i('get buttonElement failed, not need login');
      }

      //keep waiting
      var retryCount = 0;
      while (task.downloadUrl == null) {
        if (retryCount > 20) {
          TaskService.instance.updateStatus(
            id: task.id,
            status: TaskStatus.parseFailed,
            errMsg: '重试次数过多',
          );
          return;
        }
        if (task.isPaused()) {
          return;
        }
        final videokey = 'VisionVideoDetailPhoto:$videoid';
        final videoState = await page.evaluate('window.__APOLLO_STATE__');
        if (videoState != null) {
          final clients = videoState['defaultClient'];
          if (clients != null) {
            final data = clients[videokey];
            if (data != null) {
              logger.i('videoState: ${jsonEncode(data)}');
              final coverurl = data['coverUrl'];
              final videoUrl = data['photoUrl'];
              final title = data['caption'];
              final duration = data['duration'];
              logger.i('视频已加载完成:  $coverurl $videoUrl $title $duration');
              getLiveDetail = LiveDetail();
              getLiveDetail.replayUrl = videoUrl;
              getLiveDetail.coverUrl = coverurl;
              getLiveDetail.title = title;
              getLiveDetail.duration = duration ~/ 1000;
              getLiveDetail.liveId = videoid;
              break;
            }
          }
        }
        if (responseLiveDetails.containsKey(videoid)) {
          getLiveDetail = responseLiveDetails[videoid]!;
          logger.i('使用responseLiveDetails中的数据 inwhile: ${task.srcVideoTitle}');
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      }
      if (getLiveDetail != null) {
        task.srcVideoTitle = getLiveDetail.title;
        task.srcVideoCoverUrl = getLiveDetail.coverUrl;
        task.srcVideoDuration = getLiveDetail.duration;
        task.srcVideoId = getLiveDetail.liveId;
        task.downloadUrl = getLiveDetail.replayUrl;
        TaskService.instance.updateStatus(
          id: task.id,
          status: TaskStatus.parseCompleted,
        );
        return;
      }
      TaskService.instance.updateStatus(
        id: task.id,
        status: TaskStatus.parseFailed,
        errMsg: '未知错误',
      );
    } catch (e, stackTrace) {
      logger.e('使用浏览器解析链接失败', error: e, stackTrace: stackTrace);
      TaskService.instance.updateStatus(
        id: task.id,
        status: TaskStatus.parseFailed,
        errMsg: '使用浏览器解析链接失败',
      );
    } finally {
      logger.i('关闭浏览器');
      await browserSession?.close();
    }
  }
}
