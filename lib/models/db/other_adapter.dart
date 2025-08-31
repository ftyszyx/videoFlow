import 'package:hive/hive.dart';
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
