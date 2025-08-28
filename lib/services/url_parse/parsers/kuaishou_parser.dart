import 'dart:convert';

import 'package:puppeteer/puppeteer.dart';
import 'package:videoflow/entity/error.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/utils/common.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:videoflow/entity/url_parse.dart';
import 'package:videoflow/entity/common.dart';

class KuaishouParser {
  static Future<CommonResult<LiveDetail>> parse({
    required String shareText,
    required String userId,
    required Function needStop,
  }) async {
    final shortUrl = _extractShortUrl(shareText);
    if (shortUrl == null) {
      return CommonResult(success: false, error: '在分享文本中找不到有效的快手短链接');
    }
    logger.i('提取到短链接: $shortUrl');
    final result = await _getRedirectUrl(
      shortUrl: shortUrl,
      userId: userId,
      needStop: needStop,
    );
    if (!result.success) {
      return result;
    }
    final liveDetail = result.data!;
    liveDetail.platform = VideoPlatform.kuaishou;
    liveDetail.fileType = DownloadFileType.mp4;
    if (liveDetail.replayUrl.isNotEmpty) {
      final uri = Uri.parse(liveDetail.replayUrl);
      liveDetail.replayUrl = '${uri.scheme}://${uri.host}${uri.path}';
    }
    if (liveDetail.coverUrl.isNotEmpty) {
      final uri = Uri.parse(liveDetail.coverUrl);
      liveDetail.coverUrl = '${uri.scheme}://${uri.host}${uri.path}';
    }
    return CommonResult(success: true, data: liveDetail);
  }

  static String? _extractShortUrl(String text) {
    final regex = RegExp(r'https?://v\.kuaishou\.com/([a-zA-Z0-9]+)');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  static Future<CommonResult<LiveDetail>> _getRedirectUrl({
    required String shortUrl,
    required String userId,
    required Function needStop,
  }) async {
    Browser? browser;
    Page? page;
    Map<String, LiveDetail> responseLiveDetails = {};
    LiveDetail liveDetail = LiveDetail();
    try {
      logger.i('正在启动本地浏览器以解析链接 ...');
      if (needStop()) {
        return CommonResult(success: false, error: '暂停');
      }
      var userinfo = AccountService.instance.getUser(userId);
      if (userinfo == null) {
        return CommonResult(success: false, error: '用户信息未找到');
      }
      var kuaishouCookies = userinfo.kuaishouCookie;
      if (kuaishouCookies == null) {
        return CommonResult(success: false, error: '用户快手cookie未找到');
      }
      (browser, page, _) = await CommonUtils.runBrowser(
        url: shortUrl,
        cookies: kuaishouCookies,
        forceShowBrowser: false,
        onRequest: (request) {
          if (request.url.contains('.mp4')) {
            final videoUrl = Uri.parse(request.url);
            final videoUrlId = videoUrl.queryParameters['clientCacheKey'] ?? '';
            if (liveDetail.liveId.isNotEmpty &&
                videoUrlId.startsWith(liveDetail.liveId)) {
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
              final responseItem = LiveDetail();
              responseItem.liveId = responseVideoId;
              responseItem.replayUrl = feedinfo['mainMvUrls'][0]['url'];
              responseItem.coverUrl = feedinfo['coverUrls'][0]['url'];
              responseItem.title = feedinfo['caption'];
              responseItem.duration = feedinfo['duration'] ~/ 1000;
              responseLiveDetails[responseVideoId] = responseItem;
              logger.i('捕获到视频流链接  from response: $responseItem ');
            }
          }
        },
      );
      if (needStop()) {
        return CommonResult(success: false, error: '暂停');
      }
      final finalUrl = page.url!;
      logger.i('redirect url: $finalUrl');
      final uri = Uri.parse(finalUrl);
      String? photoId = uri.queryParameters['photoId'];
      if (photoId == null) {
        return CommonResult(success: false, error: '在分享文本中找不到有效的快手短链接');
      }
      final videoid = photoId;
      logger.i('视频id: $videoid');
      liveDetail.liveId = videoid;
      if (responseLiveDetails.containsKey(videoid)) {
        liveDetail = responseLiveDetails[videoid]!;
        logger.i('使用responseLiveDetails中的数据: $liveDetail');
        return CommonResult(success: true, data: liveDetail);
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
          await AccountService.instance.updateKuaishouCookie(userId, null);
          return CommonResult(success: false, error: '用户未登录');
        }
      } catch (e) {
        logger.w('get buttonElement failed, maybe not need login', error: e);
      }

      //keep waiting
      var retryCount = 0;
      while (liveDetail.replayUrl.isEmpty) {
        if (retryCount > 20) {
          return CommonResult(success: false, error: '重试次数过多');
        }
        if (needStop()) {
          return CommonResult(success: false, error: '暂停');
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
              liveDetail.replayUrl = videoUrl;
              liveDetail.coverUrl = coverurl;
              liveDetail.title = title;
              liveDetail.duration = duration ~/ 1000;
              liveDetail.liveId = videoid;
            }
          }
        }
        if (responseLiveDetails.containsKey(videoid)) {
          liveDetail = responseLiveDetails[videoid]!;
          logger.i('使用responseLiveDetails中的数据 inwhile: $liveDetail');
          return CommonResult(success: true, data: liveDetail);
        }
        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      }
    } catch (e, stackTrace) {
      logger.e('使用浏览器解析链接失败', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      logger.i('关闭浏览器');
      await browser?.close();
    }
    return CommonResult(success: false, error: '未知错误');
  }
}
