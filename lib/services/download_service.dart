import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/services/app_config_service.dart';
import 'package:videoflow/utils/logger.dart';
import 'package:videoflow/entity/common.dart';

class DownloadManagerService extends GetxService {
  static DownloadManagerService get instance =>
      Get.find<DownloadManagerService>();
  final RxMap<String, VideoTassk> _downloadTasks = <String, VideoTassk>{}.obs;
  Process? _ffmpegProcess;
  init() {
    _downloadTasks.clear();
  }

  Future<void> startDownloadTask(VideoTassk taskinfo) async {
    late VideoTassk task;
    if (_downloadTasks.containsKey(taskinfo.id)) {
      task = _downloadTasks[taskinfo.id]!;
      var status = task.status;
      if (status == TaskStatus.downloading) {
        logger.w('Task ${taskinfo.id} is already running.');
        return;
      }
      if (status == TaskStatus.downloadCompleted) {
        logger.w('Task ${taskinfo.id} is already completed.');
        return;
      }
    } else {
      _downloadTasks[taskinfo.id] = taskinfo;
      logger.i('Task ${taskinfo.id} starting ');
    }
    if (taskinfo.downloadFileType == DownloadFileType.mp4) {
      await _downloadFile(taskinfo);
    } else if (taskinfo.downloadFileType == DownloadFileType.m3u8) {
      await _downloadM3u8(taskinfo);
    } else {
      throw Exception(
        'Unsupported download file type: ${taskinfo.downloadFileType}',
      );
    }
  }

  Future<void> _downloadFileSimple(VideoTassk task) async {
    int retryCount = 0;
    while (retryCount < 3) {
      logger.i(
        'Downloading file from ${task.downloadUrl} retryCount: $retryCount',
      );
      final response = await http
          .get(Uri.parse(task.downloadUrl!))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        await File(task.downloadPath!).writeAsBytes(response.bodyBytes);
        task.status = TaskStatus.downloadCompleted;
        _downloadTasks.remove(task.id);
        logger.i(
          'Download file from ${task.downloadUrl} success. Save path: ${task.downloadPath}',
        );
        task.status = TaskStatus.downloadCompleted;
        _downloadTasks.remove(task.id);
        break;
      } else {
        retryCount++;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    if (retryCount >= 3) {
      throw Exception('Failed to download file from ${task.downloadUrl}');
    }
  }

  String getDownloadTmpPath(VideoTassk task) {
    return path.join(
      AppConfigService.instance.appCachePath,
      '${task.id}_${task.downloadFileType?.name}',
    );
  }

  Future<void> _downloadFile(VideoTassk task) async {
    final client = http.Client();
    try {
      task.status = TaskStatus.downloading;
      final headResponse = await client.head(Uri.parse(task.downloadUrl!));
      final totalSize =
          int.tryParse(headResponse.headers['content-length'] ?? '0') ?? 0;
      task.downloadFileTotalSize = totalSize;
      final acceptRanges = headResponse.headers['accept-ranges'];
      if (totalSize == 0 || acceptRanges != 'bytes') {
        logger.w(
          'Server does not support ranged requests. Falling back to single-threaded download.',
        );
        await _downloadFileSimple(task);
        return;
      }
      Directory(getDownloadTmpPath(task)).createSync(recursive: true);
      if (task.downloadSegments == null) {
        task.downloadSegments = [];
        const int maxConcurrentDownloads = 8;
        final chunkSize = (totalSize / maxConcurrentDownloads).ceil();
        for (int i = 0; i < maxConcurrentDownloads; i++) {
          final start = i * chunkSize;
          if (start >= totalSize) break;
          var end = start + chunkSize - 1;
          if (end >= totalSize) {
            end = totalSize - 1;
          }
          task.downloadSegments!.add(
            VideoTaskSegment(
              url: task.downloadUrl!,
              name: 'part_$i',
              isOk: false,
              size: end - start + 1,
              start: start,
              end: end,
            ),
          );
        }
      }
      await _downloadSegments(task);
      task.status = TaskStatus.downloadMerge;
      final finalFile = File(task.downloadPath!).openSync(mode: FileMode.write);
      try {
        for (final chunk in task.downloadSegments!) {
          if (chunk.isOk) {
            final chunkBytes = await File(chunk.name).readAsBytes();
            finalFile.writeFromSync(chunkBytes);
          }
        }
      } finally {
        await finalFile.close();
      }
      // 5. Cleanup
      Directory(getDownloadTmpPath(task)).deleteSync(recursive: true);
      task.status = TaskStatus.downloadCompleted;
      _downloadTasks.remove(task.id);
    } catch (e, s) {
      logger.e(
        'Failed to download file from ${task.downloadUrl}',
        error: e,
        stackTrace: s,
      );
      task.status = TaskStatus.downloadFailed;
    } finally {
      client.close();
    }
  }

  Future<void> _downloadSegments(VideoTassk task) async {
    int chunkIndex = -1;
    int maxConcurrentDownloads = 8;
    int totalCount = task.downloadSegments!.length;
    final client = http.Client();
    Future<void> downloadWorker() async {
      while (true) {
        if (task.status != TaskStatus.downloading) return;
        final int currentIndex = ++chunkIndex;
        if (currentIndex >= totalCount) return;
        final chunk = task.downloadSegments![currentIndex];
        if (chunk.isOk) continue;
        final start = chunk.start!;
        final end = chunk.end!;
        final chunkPath = path.join(getDownloadTmpPath(task), chunk.name);
        int retryCount = 0;
        while (retryCount < 3) {
          if (task.status != TaskStatus.downloading) return;
          try {
            final request = http.Request('GET', Uri.parse(chunk.url));
            if (chunk.start != null && chunk.end != null) {
              request.headers['Range'] = 'bytes=$start-$end';
            }
            logger.i(
              'Downloading chunk ${chunk.name} from ${task.downloadUrl} retryCount: $retryCount start: $start end: $end',
            );
            final response = await client
                .send(request)
                .timeout(const Duration(seconds: 60));
            if (response.statusCode == 206 || response.statusCode == 200) {
              final bytes = await response.stream.toBytes();
              if (task.status != TaskStatus.downloading) return;
              await File(chunkPath).writeAsBytes(bytes);
              chunk.isOk = true;
              break; // chunk downloaded successfully
            } else {
              throw Exception(
                'Failed to download chunk ${chunk.name}, status code: ${response.statusCode}',
              );
            }
          } catch (e) {
            retryCount++;
            if (task.status != TaskStatus.downloading) return;
            logger.e(
              'Error downloading chunk ${chunk.name}, retry $retryCount',
              error: e,
            );
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    }

    try {
      final workers = List.generate(
        maxConcurrentDownloads,
        (_) => downloadWorker(),
      );
      await Future.wait(workers);
      if (task.status != TaskStatus.downloading) {
        logger.i('Download for task ${task.id} was stopped.');
        return;
      }
    } finally {
      client.close();
    }
  }

  Future<void> _downloadM3u8(VideoTassk task) async {
    task.status = TaskStatus.downloading;
    if (task.downloadSegments!.isEmpty) {
      await _parseM3u8(task);
    }
    await _downloadSegments(task);
    if (task.downloadSegments!.any((chunk) => !chunk.isOk)) {
      task.status = TaskStatus.downloadFailed;
      logger.e('Download segments failed for task ${task.id}.');
      return;
    }
    await _mergeSegments(task);
    task.status = TaskStatus.downloadCompleted;
    _downloadTasks.remove(task.id);
  }

  Future<void> _parseM3u8(VideoTassk task) async {
    final m3u8Uri = Uri.parse(task.downloadUrl!);
    final response = await http.get(m3u8Uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to download M3U8 file: ${response.statusCode}');
    }
    final lines = response.body.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('#')) {
        final segmentUrl = m3u8Uri.resolve(trimmedLine).toString();
        //get segment size
        final segmentResponse = await http.head(Uri.parse(segmentUrl));
        final segmentSize =
            int.tryParse(segmentResponse.headers['content-length'] ?? '0') ?? 0;
        task.downloadSegments!.add(
          VideoTaskSegment(
            url: segmentUrl,
            name:
                '${task.downloadSegments!.length.toString().padLeft(8, '0')}.ts',
            isOk: false,
            size: segmentSize,
          ),
        );
      }
    }
  }

  Future<void> _mergeSegments(VideoTassk task) async {
    logger.i(
      'Merge segments for task $task.id start. Temp dir: ${getDownloadTmpPath(task)}, Save path: ${task.downloadPath}',
    );
    var taskOkSegmentPaths = task.downloadSegments!
        .where((chunk) => chunk.isOk)
        .toList();
    task.status = TaskStatus.downloadMerge;
    taskOkSegmentPaths.sort((a, b) => a.name.compareTo(b.name));
    final fileListContent = taskOkSegmentPaths
        .map((p) => "file '${p.name}'")
        .join('\n');
    final fileListPath = path.join(getDownloadTmpPath(task), 'filelist.txt');
    await File(fileListPath).writeAsString(fileListContent);
    final String exeDir = path.dirname(Platform.resolvedExecutable);
    final String ffmpegPath = path.join(
      exeDir,
      'data',
      'flutter_assets',
      'assets',
      'ffmpeg',
      'ffmpeg.exe',
    );
    if (!await File(ffmpegPath).exists()) {
      throw Exception('打包的 ffmpeg.exe 未找到，路径: $ffmpegPath');
    }
    if (_ffmpegProcess != null) {
      throw Exception('FFMPEG is already running');
    }
    final process = await Process.start(ffmpegPath, [
      '-f',
      'concat',
      '-safe',
      '0',
      '-i',
      fileListPath,
      '-c',
      'copy',
      task.downloadPath!,
    ]);
    _ffmpegProcess = process;

    final stdErr = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;
    _ffmpegProcess = null;
    if (exitCode != 0) {
      throw Exception('FFMPEG merge failed with exit code $exitCode.\n$stdErr');
    }
    Directory(getDownloadTmpPath(task)).deleteSync(recursive: true);
    logger.i(
      'Merge segments for task $task.id complete. Cleaning up temp files...',
    );
  }

  void stopDownload(String taskId) {
    if (_downloadTasks.containsKey(taskId)) {
      _downloadTasks[taskId]!.status = TaskStatus.downloadPaused;
      logger.i('Sending cancellation signal to task $taskId.');
      _ffmpegProcess?.kill();
      _ffmpegProcess = null;
    }
  }

  void stopAllDownloads() {
    logger.i('Stopping all active downloads...');
    for (var task in _downloadTasks.values) {
      stopDownload(task.id);
    }
    logger.i(
      'All active downloads have been sent the kill/cancellation signal.',
    );
  }

  void dispose() {
    logger.i('Disposing download manager');
    stopAllDownloads();
  }
}
