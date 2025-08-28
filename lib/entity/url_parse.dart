import 'dart:convert';

class LiveDetail {
  String replayUrl;
  String title;
  String liveId;
  String coverUrl;
  int duration;
  int size;
  LiveDetail({
    this.replayUrl = '',
    this.title = '',
    this.liveId = '',
    this.coverUrl = '',
    this.duration = 0,
    this.size = 0,
  });
  @override
  String toString() => jsonEncode({
    'replayUrl': replayUrl,
    'title': title,
    'liveId': liveId,
    'coverUrl': coverUrl,
    'duration': duration,
    'size': size,
  });
}
