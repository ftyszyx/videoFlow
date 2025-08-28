enum DownloadFileType { m3u8, mp4, unknown }

enum VideoPlatform {
  kuaishou('快手'),
  taobao('淘宝'),
  unknown('未知');

  final String title;
  const VideoPlatform(this.title);
}

enum TaskStatus {
  init('初始化', 0),
  parseUrl('解析链接', 1),
  parsePause('解析暂停', 2),
  parseFailed('解析失败', 3),
  parseCompleted('解析完成', 4),
  downloading('下载中', 5),
  downloadFailed('下载失败', 6),
  downloadPaused('下载暂停', 7),
  downloadMerge('下载合并', 8),
  downloadCompleted('下载完成', 9),
  videoMerge('视频合并', 10),
  videoMergeFailed('视频合并失败', 11),
  videoMergePaused('视频合并暂停', 12),
  videoMergeCompleted('视频合并完成', 13),
  addCover('添加封面', 14);

  final String title;
  final int code;
  const TaskStatus(this.title, this.code);
}
