import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:puppeteer/protocol/network.dart';
import 'package:videoflow/entity/common.dart';

class DownloadFileTypeAdapter extends TypeAdapter<DownloadFileType> {
  @override
  final int typeId = 7; // ensure unique id across adapters

  @override
  DownloadFileType read(BinaryReader reader) {
    final index = reader.readByte();
    return DownloadFileType.values[index];
  }

  @override
  void write(BinaryWriter writer, DownloadFileType obj) {
    writer.writeByte(obj.index);
  }
}

class CookieAdapter extends TypeAdapter<Cookie> {
  @override
  final int typeId = 8; // ensure unique id across adapters

  @override
  Cookie read(BinaryReader reader) {
    var json = jsonDecode(reader.readString());
    return Cookie.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Cookie obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}
